require 'rails_helper'

describe Api::V2::PostsController, type: :controller do
  before(:each) do
    load 'support/rails_app/db/schema.rb'
  end

  context 'create' do
    it 'uses the operation' do
      post :create

      expect(response.body).to eq 'namespaced operation'
    end
  end
end
