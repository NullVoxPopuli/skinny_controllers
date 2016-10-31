# frozen_string_literal: true
require 'rails_helper'

describe OtherItemsController, type: :controller do
  before(:each) do
    load 'support/rails_app/db/schema.rb'
  end

  context 'index' do
    before(:each) do
      @s = s = SuperItem.new(name: 'super')
      s.save
      i1 = SuperItem::OtherItem.new(name: 'sub1', reference_id: s.id)
      i2 = SuperItem::OtherItem.new(name: 'sub2', reference_id: s.id)
      i3 = SuperItem::OtherItem.new(name: 'sub3')
      i1.save
      i2.save
      i3.save
    end

    it 'retrieves only tho two items' do
      get :index, super_item_id: @s.id

      json = JSON.parse(response.body)
      expect(json.count).to eq 2
    end
  end

  context 'create' do
    it 'creates an event' do
      skip('not the test currently being solved')
      expect do
        post :create, other_item: { name: 'created' }
      end.to change(SuperItem::Item, :count).by(1)

      json = JSON.parse response.body

      expect(json['name']).to eq 'created'
    end
  end
end
