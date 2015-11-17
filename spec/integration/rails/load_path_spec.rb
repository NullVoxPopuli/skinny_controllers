require 'rails_helper'


describe 'definitions of operations and policies' do

  it 'loads operations' do
    is_defined = defined? EventOperations
    expect(is_defined).to be_truthy
  end

  it 'loads policies' do
    is_defined = defined? EventPolicy
    expect(is_defined).to be_truthy
  end
end
