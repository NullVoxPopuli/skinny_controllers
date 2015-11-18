require 'rails_helper'

describe EventsController, type: :controller do
  before(:each) do
    load 'support/rails_app/db/schema.rb'
  end

  it 'returns an empty set of events' do
    get :index

    expect(response.body).to eq '[]'
  end

  context 'events exist' do
    let(:event1) { create(:event) }
    let(:event2) { create(:event) }
    let(:event3) { create(:event) }

    it 'returns a list of events' do
      get :index
      json = JSON.parse(response.body)
      expect(json.count).to eq Event.all.count
    end

    it 'filters events based on a list of ids' do
      ids = [event1.id, event2.id]
      get :index, filter: { id: ids }

      json = JSON.parse(response.body)
      expect(json.count).to eq 2
      expect(ids).to include(json.first['id'])
      expect(ids).to include(json.last['id'])
    end
  end
end

describe DiscountsController, type: :controller do
  before(:each) do
    load 'support/rails_app/db/schema.rb'
    @event = create(:event)
  end

  it 'returns a list of discounts scoped to the event' do
    discount = create(:discount, event: @event)

    # TODO: how do we require the scope?
    # -- authorize the parent, unauthorize the child
    get :index, scope: { id: @event.id, type: @event.class.name }
    json = JSON.parse(response.body)


    expect(json.count).to eq 1
    expect(json.first['id']).to eq discount.id
  end
end
