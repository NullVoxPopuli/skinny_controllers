class ExamplePolicy < SkinnyControllers::Policy::Base
  def read?
    object.is_accessible_to? user
  end
end
