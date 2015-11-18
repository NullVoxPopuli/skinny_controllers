require 'rails_helper'

describe EventSummariesController, type: :controller do
  before(:each) do
    load 'support/rails_app/db/schema.rb'
  end

  it 'renders the event as there is no event summary' do
    event = create(:event)
    get :show, id: event.id

    json = JSON.parse(response.body)
    expect(json['id']).to eq event.id
  end

end
