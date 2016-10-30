module SkinnyControllers
  class Lookup
    module EnsureExistence
      module_function

      # @return [Module] namespace
      def ensure_namespace!(namespace)
        Namespace.create_namespace(namespace)
      end

      def ensure_operation_class!(qualified_name)
        klass = operation_lookup(qualified_name)
        klass || use_defailt_operation(qualified_name)
      end

      def ensure_policy_class!(qualified_name)
        klass = policy_lookup(qualified_name)
        klass || Lookup::Policy.define_policy_class(qualified_name)
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

    def policy_lookup(qualified_name)
      return if qualified_name.blank?
      klass = qualified_name.safe_constantize

      # Return if the constant exists, or if we can't travel
      # up any higher.
      return klass if klass
      return unless qualified_name.include?('::')

      # "Api::V1::CategoryPolicy"
      # => "CategorPolicy"
      target = qualified_name.demodulize

      # "Api::V1::CategoryPolicy"
      # => "Api"
      namespace = qualified_name.deconstantize.deconstantize
      next_lookup = [namespace, target].reject(&:blank?).join('::')

      # recurse
      policy_lookup(next_lookup)
    end

    def operation_lookup(qualified_name)
      return if qualified_name.blank?
      klass = qualified_name.safe_constantize

      # Return if the constant exists, or if we can't travel
      # up any higher.
      return klass if klass
      return unless qualified_name.scan(/::/).count > 2

      # "Api::V1::CategoryOperations::Create"
      # => "CategorOperations::Create"
      parts = qualified_name.split('::')
      target = parts[-2..-1]

      # "Api::V1::CategoryPolicy"
      # => "Api"
      namespace = parts[0..-4]
      next_lookup = [namespace, target].reject(&:blank?).join('::')

      # recurse
      operation_lookup(next_lookup)
    end
  end
end
