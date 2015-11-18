require 'rails_helper'

describe UsersController, type: :controller do
  before(:each) do
    load 'support/rails_app/db/schema.rb'
  end

  context 'show' do
    it 'does not render the model (policy is DenyAll)' do
      user = create(:user)

      get :show, id: user.id
      # TODO: Find out the JSON API way to render errors
      expect(response.body).to eq 'null'
    end
  end
end
