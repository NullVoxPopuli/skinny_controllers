require 'spec_helper'

describe 'Access' do
  context 'a user does not have access' do
    let(:example) { Example.new }
    before(:each) do
      expect(example).to receive(SkinnyControllers.accessible_to_method) { false }
      allow(Example).to receive(:find) { example }
    end

    it 'returns nil' do
      result = ExampleOperations::Read.new(TestUser.new, id: 1).run
      expect(result).to eq nil
    end
  end

  context 'a user does have access' do
    let(:example) { Example.new }
    before(:each) do
      expect(example).to receive(SkinnyControllers.accessible_to_method) { true }
      allow(Example).to receive(:find) { example }
    end

    it 'returns the model' do
      result = ExampleOperations::Read.new(TestUser.new, id: 1).run
      expect(result).to eq example
    end
  end
end
