module Policy
  class ExampleOperationPolicy < SkinnyControllers::Policy::Base
    def read?
      object.is_accessible_to? user
    end
  end
end
