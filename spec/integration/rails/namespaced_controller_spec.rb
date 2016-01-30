require 'rails_helper'

describe ItemsController, type: :controller do
  before(:each) do
    load 'support/rails_app/db/schema.rb'
  end

  context 'create' do
    it 'creates an event' do
      expect do
        post :create, item: { name: 'created' }
      end.to change(SuperItem::Item, :count).by(1)

      json = JSON.parse response.body

      ap json
      expect(json['name']).to eq 'created'
    end
  end
end
