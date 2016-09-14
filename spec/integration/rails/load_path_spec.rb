# frozen_string_literal: true
require 'rails_helper'

describe 'definitions of operations and policies' do
  # HACK: to get the environment loaded
  describe EventsController, type: :controller do
    before(:each) do
      get :load_hack
    end

    it 'loads operations' do
      is_defined = defined? EventOperations
      expect(is_defined).to be_truthy
    end

    it 'loads policies' do
      is_defined = defined? EventPolicy
      expect(is_defined).to be_truthy
    end
  end
end
