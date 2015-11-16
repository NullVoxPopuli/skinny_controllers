module SkinnyControllers
  module Operation
    class Default < Base
      def run
        model if allowed?
      end
    end
  end
end
