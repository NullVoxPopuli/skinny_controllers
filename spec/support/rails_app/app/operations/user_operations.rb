module UserOperations
  class Read < SkinnyControllers::Operation::Base
    def run
      model if allowed?
    end
  end

  class ReadAll < SkinnyControllers::Operation::Base
    def run
      model if allowed?
    end
  end

  class Delete < SkinnyControllers::Operation::Base
    def run
      model.destroy if allowed?
    end
  end
end
