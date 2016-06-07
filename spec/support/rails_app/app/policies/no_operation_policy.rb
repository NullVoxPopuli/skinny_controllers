class NoOperationPolicy < SkinnyControllers::Policy::Base

  def read?
    user.present?
  end
end
