# frozen_string_literal: true
require 'spec_helper'

describe SkinnyControllers::Lookup::Policy do
  let(:klass) { SkinnyControllers::Lookup::Policy }

  context :class_from_model do
    it 'returns the policy class' do
      result = klass.class_from_model(Example.name)
      expect(result).to eq ExamplePolicy
    end
  end

  context :method_name_for_operation do
    it 'returns the policy name, given a proper operation class name' do
      result = klass.method_name_for_operation(ExampleOperations::Read.name)
      expect(result).to eq 'read?'
    end

    it 'returns the multi-word policy name, given a proper operation class name' do
      result = klass.method_name_for_operation(ExampleOperations::ReadAll.name)
      expect(result).to eq 'read_all?'
    end
  end
end
