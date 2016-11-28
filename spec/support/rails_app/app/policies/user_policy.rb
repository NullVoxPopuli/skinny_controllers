# frozen_string_literal: true
class UserPolicy < SkinnyControllers::Policy::DenyAll
  # exceptions to the DenyAll rule may be defined here

  # allow if we are deleting ourselves / cancelling our account
  def delete?
    object.is_accessible_to?(user)
  end
end
