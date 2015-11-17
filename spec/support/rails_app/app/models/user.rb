class User < ActiveRecord::Base
  has_many :events
end
