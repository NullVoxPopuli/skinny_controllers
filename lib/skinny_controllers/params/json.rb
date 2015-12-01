module SkinnyControllers
  module Params
    class Json
      attr_accessor :document, :model_key
      # @param [Params] params from controller
      def initialize(params, model_key)
        self.document = params
        self.model_key = model_key
      end

      def model_params
        document[model_key].symbolize_keys
      end

      def id
        document[:id]
      end
    end
  end
end
