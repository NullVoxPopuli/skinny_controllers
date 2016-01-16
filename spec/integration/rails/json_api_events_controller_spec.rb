require 'rails_helper'

describe JsonApiEventsController, type: :controller do
  context 'destroy' do
    it 'destroys a record, ignoring event_params' do
      event = create(:event)
      expect{
        delete :destroy, id: event.id
      }.to change(Event, :count).by(-1)
    end
  end
end
