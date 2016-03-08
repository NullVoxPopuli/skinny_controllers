require 'rails_helper'

describe EventOperations do
  describe :find_model do
    it 'detects a parent.child.find relationship' do
      event = create(:event)
      create(:discount, event: event)
      discount = create(:discount, event: event)

      # note that parameters in the controller are indifferent keys,
      # which means we should treat them as strings here
      # because the ModelHelper performs string operations on the keys
      params = { 'event_id' => event.id, 'id' => discount.id }
      op = DiscountOperations::Read.new(event.user, params)

      expect(op).to receive(:model_from_parent)
      expect(op).to_not receive(:model_from_scope) # cause execution halts
      expect(op).to_not receive(:model_from_named_id)
      expect(op).to_not receive(:model_from_id)
      expect(op).to_not receive(:model_from_params)
      result = op.find_model
    end
  end

  describe :model_from_parent do
    it 'returns one model when parent is specified' do
      event = create(:event)
      create(:discount, event: event)
      discount = create(:discount, event: event)

      # note that parameters in the controller are indifferent keys,
      # which means we should treat them as strings here
      # because the ModelHelper performs string operations on the keys
      params = { 'event_id' => event.id, 'id' => discount.id }
      op = DiscountOperations::Read.new(event.user, params)

      result = op.model_from_parent('Event', event.id, discount.id)
      expect(result).to eq discount
    end
  end
end
