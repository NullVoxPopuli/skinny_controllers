# frozen_string_literal: true
require 'rails_helper'

describe JsonApiEventsController, type: :controller do
  context 'destroy' do
    it 'destroys a record, ignoring event_params' do
      event = create(:event)
      expect do
        delete :destroy, params: { id: event.id }
      end.to change(Event, :count).by(-1)
    end
  end
end
