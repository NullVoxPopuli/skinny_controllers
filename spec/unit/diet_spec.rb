require 'spec_helper'

describe SkinnyControllers::Diet do
  #
  # RSpec.describe FakeObjectsController, :type => :controller do
  #   controller do
  #     include
  #   end
  # end
  class FakeObjectsController < FakeController
    include SkinnyControllers::Diet
  end

  class ExampleOperationsController < FakeController
    include SkinnyControllers::Diet
  end

  module API
    class SomeObjectsController < FakeController
      include SkinnyControllers::Diet
    end
  end

  let(:controller) { FakeObjectsController.new }
  let(:some_controller) { API::SomeObjectsController.new }
  let(:example) { ExampleOperationsController.new }

  context :default_operation_class_for do
    it 'creates a namespace' do
      expect(defined? SkinnyControllers::Operation::SomeObject::Default).to be_falsey
      some_controller.default_operation_class_for('SomeObject')
      expect(defined? SkinnyControllers::Operation::SomeObject::Default).to be_truthy
    end
  end

  context :default_operation_namespace_for do
    before(:each) do
      # just in case of race conditions
      if defined? SkinnyControllers::Operation::SomeObject
        SkinnyControllers::Operation.send(:remove_const, :SomeObject)
      end
    end

    it 'creates a namespace' do
      expect(defined? SkinnyControllers::Operation::SomeObject).to be_falsey
      some_controller.default_operation_namespace_for('SomeObject')
      expect(defined? SkinnyControllers::Operation::SomeObject).to be_truthy
    end
  end

  context :operation do
    let(:operation_class) { Operation::ExampleOperation::Read }
    before(:each) do
      allow(example).to receive(:verb_for_action) { operation_class }
      allow(example).to receive(:verb_for_action) { SkinnyControllers::DefaultVerbs::Read }
    end

    it 'creates a new operation' do
      operation = example.operation
      expect(operation).to be_a_kind_of operation_class
    end

    it 'does not create the operation more than once' do
      expect(operation_class).to receive(:new).once.and_call_original
      expect(example.operation).to eq example.operation
    end
  end

  context :operation_class do
    it 'gets the default operation class' do
      klass = controller.operation_class
      expect(klass).to eq SkinnyControllers::Operation::FakeObject::Default
    end

    it 'gets an explicitly defined operation class' do
      allow(example).to receive(:verb_for_action) { SkinnyControllers::DefaultVerbs::Read }
      klass = example.operation_class
      expect(klass).to eq Operation::ExampleOperation::Read
    end
  end

  context :model do
    before(:each) do
      allow(example).to receive(:params) { { id: 1 } }
    end

    context 'action is defined' do
      before(:each) do
        allow(example).to receive(:verb_for_action) { SkinnyControllers::DefaultVerbs::Read }
      end

      it 'runs the operation only once' do
        expect(example.operation).to receive(:run).once.and_call_original
        example.model
        example.model
      end

      it 'returns the model' do
        expect(example.model).to be_a_kind_of ExampleOperation
      end
    end

    context 'action is not explicitly defined' do
      it 'returns the model' do
        expect(example.model).to be_a_kind_of ExampleOperation
      end
    end
  end

  context :resource_name_from_controller do
    it 'removes controller' do
      result = controller.send(:resource_name_from_controller)
      expect(result).to eq 'FakeObjects'
    end
  end

  context :model_name_from_controller do
    it 'resembles a class' do
      name = controller.send(:model_name_from_controller)
      expect(name).to eq 'FakeObject'
    end

    it 'removes the prefix when there is none' do
      allow(controller).to receive(:controller_name_prefix) { 'API::' }
      name = controller.send(:model_name_from_controller)
      expect(name).to eq 'FakeObject'
    end

    it 'removes the prefix when there actually is a prefix to remove' do
      allow(some_controller).to receive(:controller_name_prefix) { 'API::' }
      name = some_controller.send(:model_name_from_controller)
      expect(name).to eq 'SomeObject'
    end
  end

  context :operation_class_from_model do
    it 'prepends the operation prefix' do
      verb = SkinnyControllers::DefaultVerbs::ReadAll
      allow(some_controller).to receive(:verb_for_action) { verb }
      name = 'SomeObject'

      expected = SkinnyControllers.operation_namespace + '::' + name + '::' + verb
      result = some_controller.send(:operation_class_from_model, name)

      expect(result).to eq expected
    end
  end

  context :controller_name_prefix do
    it 'adds :: to the prefix' do
      allow(SkinnyControllers).to receive(:controller_namespace) { 'API' }
      prefix = controller.send(:controller_name_prefix)

      expect(prefix).to eq 'API::'
    end
  end
end
