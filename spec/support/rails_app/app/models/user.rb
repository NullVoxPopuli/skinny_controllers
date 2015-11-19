class User < ActiveRecord::Base
  has_many :events

  # realistically, you'd only want users to be able to access themselves
  def is_accessible_to?(user)
    id == user.id
  end
end
