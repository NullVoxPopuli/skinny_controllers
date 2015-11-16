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

  context :operation do
  end

  context :operation_class do
    it 'gets the default operation class' do
      klass = controller.operation_class
      expect(klass).to eq SkinnyControllers::Operation::Default
    end

    it 'gets an explicitly defined operation class' do
      allow(example).to receive(:verb_for_action) { SkinnyControllers::DefaultVerbs::Read }
      klass = example.operation_class
      expect(klass).to eq Operation::ExampleOperation::Read
    end
  end

  context :model do
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
  end
end
