# frozen_string_literal: true
require 'rails_helper'

describe NoOperationsController, type: :controller do
  before(:each) do
    load 'support/rails_app/db/schema.rb'
  end

  context 'show' do
    it 'gets the model - because the current_user is passed
        through the anonymous operation to the explicit policy' do
      allow(controller).to receive(:current_user) { create(:user) }
      no_operation = create(:no_operation)

      get :show, params: { id: no_operation.id }
      expect(response.status).to eq 200

      json = JSON.parse(response.body)
      expect(json['id']).to eq no_operation.id
    end
  end

  context 'create' do
    it 'creates' do
      expect do
        post :create, params: { no_operation: {} }
      end.to change(NoOperation, :count).by(1)
    end
  end
end
