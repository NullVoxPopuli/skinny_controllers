module Operation
  module ExampleOperation
    class Read < SkinnyControllers::Operation::Base
    def run
      model if allowed?
    end
    end
  end
end
