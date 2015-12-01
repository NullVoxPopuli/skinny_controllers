module SkinnyControllers
  module Params
    class JsonApi
      attr_accessor :document, :model_key

      # @param [Params] params from controller
      def initialize(params, model_key)
        self.document = JsonApiDocument.new(params)
        self.model_key = model_key
      end

      def model_params
        document.attributes
      end

      def id
        document.id
      end
    end
  end
end
