# frozen_string_literal: true
require 'spec_helper'

describe SkinnyControllers::Lookup::Model do
  let(:klass) { SkinnyControllers::Lookup::Model }
  context :class_from_operation_name do
  end

  context :name_from_operation do
    it 'handles regular models' do
      operation_name = 'ItemOperations::Default'

      result = klass.name_from_operation(operation_name)
      expect(result).to eq 'Item'
    end

    it 'handles namespaced models' do
      operation_name = 'SuperItem::ItemOperations::Default'

      result = klass.name_from_operation(operation_name)
      expect(result).to eq 'SuperItem::Item'
    end
  end
end
