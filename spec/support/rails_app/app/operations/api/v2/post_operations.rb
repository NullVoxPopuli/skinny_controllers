module Api
  module V2
    module PostOperations
      class Create < SkinnyControllers::Operation::Base
        def run
          'namespaced operation'
        end
      end
    end
  end
end
