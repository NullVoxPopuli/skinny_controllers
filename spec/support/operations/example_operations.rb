module ExampleOperations
  class ReadAll < SkinnyControllers::Operation::Base
    def run
      model
    end
  end
  class Read < SkinnyControllers::Operation::Base
    def run
      model if allowed?
    end
  end

  class Update < SkinnyControllers::Operation::Base
  end
end
