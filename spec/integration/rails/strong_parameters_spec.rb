require 'rails_helper'

describe StrongParametersController, type: :controller do

  context '{model}_params' do
    it 'calls the model params' do
      expect(controller).to receive(:event_params).and_call_original

      post :create, event: { name: 'created' }
    end
  end

  context '{action}_{model}_params' do
    it 'calls the action params' do
      expect(controller).to receive(:update_event_params).and_call_original
      event = create(:event)

      put :update, id: event.id, event: { name: 'updated' }
    end
  end

  context 'no strong parameters used' do

  end
end
