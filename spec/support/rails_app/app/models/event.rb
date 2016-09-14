# frozen_string_literal: true
class Event < ActiveRecord::Base
  belongs_to :user
  has_many :discounts
end
