require 'spec_helper'

describe 'Access' do
  context 'a user does not have access' do
    let(:example) { ExampleOperation.new }
    before(:each) do
      expect(example).to receive(SkinnyControllers.accessible_to_method) { false }
      allow(ExampleOperation).to receive(:find) { example }
    end

    it 'returns nil' do
      result = Operation::ExampleOperation::Read.new(User.new, id: 1).run
      expect(result).to eq nil
    end
  end

  context 'a user does have access' do
    let(:example) { ExampleOperation.new }
    before(:each) do
      expect(example).to receive(SkinnyControllers.accessible_to_method) { true }
      allow(ExampleOperation).to receive(:find) { example }
    end

    it 'returns the model' do
      result = Operation::ExampleOperation::Read.new(User.new, id: 1).run
      expect(result).to eq example
    end
  end
end
