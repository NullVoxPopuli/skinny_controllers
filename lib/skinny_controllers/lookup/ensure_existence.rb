module SkinnyControllers
  class Lookup
    module EnsureExistence
      module_function

      # @return [Module] namespace
      def ensure_namespace!(namespace)
        Namespace.create_namespace(namespace)
      end

      def ensure_operation_class!(qualified_name)
        klass = qualified_name.safe_constantize
        klass || use_defailt_operation(qualified_name)
      end

      # This assumes the namespace already exists
      # This is only to be used if there does not exist
      # operation that goes by the name defined by
      # qualified_name (hence the warn log at the top)
      #
      # @param [String] qualified_name the name of the class to create
      # @example 'Api::V2::PostOperations::Create'
      #
      # @return [Class] a duplicate of the default operation
      def use_defailt_operation(qualified_name)
        SkinnyControllers.logger.warn("#{qualified_name} not found. Creating default...")

        parts = qualified_name.split('::')
        class_name = parts.pop
        namespace = parts.join('::').safe_constantize

        namespace.const_set(
          class_name,
          SkinnyControllers::Operation::Default.dup
        )
      end
    end

    def ensure_policy_class!(qualified_name)
      qualified_name.safe_constantize ||
        Lookup::Policy.define_policy_class(qualified_name)
    end
  end
end
