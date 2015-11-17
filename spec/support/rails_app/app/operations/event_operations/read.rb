module EventOperations
  class Read < SkinnyControllers::Operation::Base
    def run
      model if allowed?
    end
  end
end
