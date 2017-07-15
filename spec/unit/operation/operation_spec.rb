# frozen_string_literal: true
require 'spec_helper'

describe ExampleOperations::Read do
  let(:klass) { ExampleOperations::Read }

  describe 'static shorthand access' do
    it 'creates and runs the opreation' do
      skip 'No idea why self.new in a class method returns nil'
      expect(ExamplePolicy).to receive(:allowed?)
      expect(ExampleOperations::Read).to receive(:new)

      Operation::ExampleOperations::Read.run(TestUser.new, {})
    end
  end

  context :instantiation do
    it 'sets accessors' do
      user = TestUser.new
      params = { "a" => :b }
      operation = klass.new(user, params)
      expect(operation.current_user).to eq user
      expect(operation.params).to eq params
    end
  end

  describe :model_class do
    it 'determines the object class' do
      op = klass.new(nil, {})
      expect(op.model_class).to eq Example
    end
  end

  describe :model_name do
    it 'determines the object class name' do
      op = klass.new(nil, {})
      expect(op.model_name).to eq Example.name
    end
  end

  describe :policy_class do
    it 'derives the class for the policy' do
      op = klass.new(nil, {})
      expect(op.policy_class).to eq ExamplePolicy
    end
  end

  describe :policy_method_name do
    it 'derives the policy name from the operation name' do
      op = klass.new(nil, {})
      expect(op.policy_method_name).to eq 'read?'
    end

    it 'derives the method name even if it does not exist on the policy' do
      # it's the policies job to handle missing methods
      op = ExampleOperations::Update.new(nil, {})
      expect(op.policy_method_name).to eq 'update?'
    end
  end

  describe :allowed_for? do
    it 'invokes the policy name' do
      op = klass.new(nil, {})
      policy = ExamplePolicy.new(nil, nil)

      allow(op).to receive(:policy_for) { policy }
      allow(policy).to receive(:read?)
      expect(policy).to receive(:read?)

      # object doesn't matter here, cause we don't care about the value
      # of the policy
      op.allowed_for?(nil)
    end
  end
end
