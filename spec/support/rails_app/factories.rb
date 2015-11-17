FactoryGirl.define do

  factory :user do

  end

  factory :event do
    name "Test Event"
    association :user, factory: :user
  end

  factory :discount do
    name "Some Discount"
    event
  end

end
