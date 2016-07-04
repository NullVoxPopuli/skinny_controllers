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

  class ExamplesController < FakeController
    include SkinnyControllers::Diet
  end

  module API
    class SomeObjectsController < FakeController
      include SkinnyControllers::Diet
    end
  end

  let(:controller) { FakeObjectsController.new }
  let(:some_controller) { API::SomeObjectsController.new }
  let(:example) { ExamplesController.new }

  context :operation do
    let(:operation_class) { ExampleOperations::Read }
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
    it 'gets an explicitly defined operation class' do
      allow(example).to receive(:verb_for_action) { SkinnyControllers::DefaultVerbs::Read }
      klass = example.operation_class
      expect(klass).to eq ExampleOperations::Read
    end

    it 'gets an arbitrary operation class' do
      allow(example).to receive(:verb_for_action) { 'RefundPayment'.freeze }
      klass = example.operation_class
      expect(klass).to eq ExampleOperations::RefundPayment
    end

    it 'derives from params action' do
      allow(example).to receive(:action_name) { 'refund_payment' }
      klass = example.operation_class
      expect(klass).to eq ExampleOperations::RefundPayment
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
        expect(example.model).to be_a_kind_of Example
      end
    end

    context 'action is not explicitly defined' do
      it 'returns the model' do
        expect(example.model).to be_a_kind_of Example
      end
    end
  end

  context :controller_name_prefix do
    it 'adds :: to the prefix' do
      allow(SkinnyControllers).to receive(:controller_namespace) { 'API' }
      prefix = SkinnyControllers::Lookup::Controller.namespace

      expect(prefix).to eq 'API::'
    end
  end
end
