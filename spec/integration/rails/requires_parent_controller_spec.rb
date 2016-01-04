require 'rails_helper'

describe RequiresParentController, type: :controller do
  before(:each) do
    load 'support/rails_app/db/schema.rb'
  end

  context 'index' do
    it 'is scoped to a parent relationship' do
      event = create(:event)
      create(:discount)
      discount = create(:discount, event: event)

      get :index, event_id: event.id

      json = JSON.parse(response.body)
      expect(json.count).to eq 1
      expect(json.first['id']).to eq discount.id
    end

    it 'does not include discounts from other events' do
      event = create(:event)
      notthis = create(:discount)
      discount = create(:discount, event: event)

      get :index, event_id: event.id

      json = JSON.parse(response.body)
      expect(json.count).to eq 1
      expect(json).to_not eq(notthis)
      expect(json.first['id']).to eq discount.id
    end
  end

  context 'show' do
    it 'is scoped to the parent relationship' do
      event = create(:event)
      create(:discount)
      discount = create(:discount, event: event)

      get :show, id: discount.id, event_id: event.id

      json = JSON.parse(response.body)
      expect(json.first['id']).to eq discount.id
    end

    it 'does not retrieve a discount from another event' do
      event = create(:event)
      notthis = create(:discount)
      discount = create(:discount, event: event)

      get :show, id: discount.id, event_id: event.id

      json = JSON.parse(response.body)
      expect(json.first['id']).to_not eq notthis.id
    end
  end

end
