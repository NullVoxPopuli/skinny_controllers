require 'rails_helper'

describe JsonApiEventsController, type: :controller do
  context 'JSON API Support' do
    context 'create / POST' do
      it 'creates a resource' do
        json_api = {
          'data' => {
            'attributes' => {
              'name' => 'new_name'
            },
            'type' => 'events'
          }
        }

        expect do
          post :create, json_api
        end.to change(Event, :count).by(1)
      end
    end

    context 'update / PATCH' do
      it 'updates a resource' do
        event = create(:event)
        new_name = event.name + ' Updated'

        json_api = {
          id: event.id,
          'data' => {
            'id' => event.id.to_s,
            'attributes' => {
              'name' => new_name
            },
            'type' => 'events'
          },
          format: 'json'
        }

        patch :update, json_api

        expect(Event.find(event.id).name).to eq new_name
      end
    end
  end
end
