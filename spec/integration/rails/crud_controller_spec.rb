# frozen_string_literal: true
require 'rails_helper'

describe UsersController, type: :controller do
  context 'destroy with explicit destroy operation' do
    it 'is allowed' do
      user = create(:user)
      allow(controller).to receive(:current_user) { user }

      expect do
        delete :destroy, id: user.id
      end.to change(User, :count).by(-1)
    end

    it 'is not allowed' do
      current_user = create(:user)
      user = create(:user)

      # set the current user
      allow(controller).to receive(:current_user) { current_user }

      expect do
        delete :destroy, id: user.id
      end.to change(User, :count).by(0)
    end
  end
end

describe EventsController, type: :controller do
  context 'create' do
    it 'creates an event' do
      expect do
        post :create, event: { name: 'created' }
      end.to change(Event, :count).by(1)

      json = JSON.parse response.body

      expect(json['name']).to eq 'created'
    end
  end

  context 'update' do
    it 'updates an existing event' do
      event = create(:event)
      name = event.name + ' updated'
      put :update, id: event.id, event: { name: name }
      json = JSON.parse response.body

      expect(json['name']).to eq name
    end
  end

  context 'destroy' do
    it 'destroys an existing event' do
      event = create(:event)
      expect do
        delete :destroy, id: event.id
      end.to change(Event, :count).by(-1)
    end
  end
end
