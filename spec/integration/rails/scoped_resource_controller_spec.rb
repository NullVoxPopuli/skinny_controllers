# frozen_string_literal: true
require 'rails_helper'

describe DiscountsController, type: :controller do
  before(:each) do
    load 'support/rails_app/db/schema.rb'
    @event = create(:event)
  end

  it 'calls a non-crud action' do
    discount = create(:discount, event: @event)
    expect_any_instance_of(DiscountOperations::RefundPayment).to receive(:run).and_call_original
    get :refund_payment, params: { id: discount.id }
  end

  it 'returns a list of discounts scoped to the event' do
    discount = create(:discount, event: @event)

    # TODO: how do we require the scope?
    # -- authorize the parent, unauthorize the child
    get :index, params: { scope: { id: @event.id, type: @event.class.name } }
    json = JSON.parse(response.body)

    expect(json.count).to eq 1
    expect(json.first['id']).to eq discount.id
  end

  context 'named_id is used for scoping' do
    context 'show' do
      it 'finds a single record scoped to the parent' do
        skip 'need to write this test'
      end

      it 'does not find a single record, cause the parent info is wrong' do
        skip 'write this'
      end

      it 'does not find a single record, cause the user does not have access to the parent' do
        skip 'write this'
      end
    end

    context 'index' do
      it 'scopes by named_id' do
        discount = create(:discount, event: @event)

        # TODO: how do we require the scope?
        # -- authorize the parent, unauthorize the child
        get :index, params: { event_id: @event.id }
        json = JSON.parse(response.body)

        expect(json.first['id']).to eq discount.id
      end

      it 'does not find the discount, because the event is wrong' do
        create(:discount, event: @event)
        wrong_event = create(:event)
        get :index, params: { event_id: wrong_event.id }
        json = JSON.parse(response.body)

        expect(json).to be_empty
      end
    end
  end
end
