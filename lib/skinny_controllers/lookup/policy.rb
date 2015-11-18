module SkinnyControllers
  module Lookup
    module Policy
      module_function

      # @param [String] name the name of the model
      # @return [Class] the policy class
      def class_from_model(name)
        (
          "#{namespace}::#{name}" +
          SkinnyControllers.policy_suffix
        ).constantize
      end

      # @param [String] class_name name of the operation class
      def method_name_for_operation(class_name)
        class_name.demodulize.downcase + POLICY_METHOD_SUFFIX
      end

      def namespace
        SkinnyControllers.policies_namespace
      end
    end
  end
end
