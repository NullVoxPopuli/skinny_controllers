# frozen_string_literal: true
require 'rails_helper'

describe ItemsController, type: :controller do
  before(:each) do
    load 'support/rails_app/db/schema.rb'
  end

  context 'create' do
    it 'creates an event' do
      expect do
        post :create, params: { item: { name: 'created' } }
      end.to change(SuperItem::Item, :count).by(1)

      json = JSON.parse response.body

      expect(json['name']).to eq 'created'
    end
  end
end
