module SkinnyControllers
  class Lookup
    module EnsureExistence
      module_function

      # @return [Module] namespace
      def ensure_namespace!(namespace)
        klass = namespace_lookup(namespace)
        klass || Namespace.create_namespace(namespace)
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

    def namespace_lookup(qualified_name)
      klass, name_flag = lookup_helper(qualified_name, __method__)
      return klass if name_flag

      parts = qualified_name.split('::')

      # Api::V2::CategoriesNamespace
      # => Api::CategoriesNamespace
      demodulized = qualified_name.demodulize
      namespace = parts[0..-3]
      next_lookup = [namespace, demodulized].reject(&:blank?).join('::')
      result = namespace_lookup(next_lookup)
      return result if result

      # Api::V2::CategoriesNamespace
      # => V2::CategoriesNamespace
      next_lookup = parts[1..-1].join('::')
      namespace_lookup(next_lookup)
    end

    def policy_lookup(qualified_name)
      klass, name_flag = lookup_helper(qualified_name, __method__)
      return klass if name_flag

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
      klass, name_flag = lookup_helper(qualified_name, __method__)
      return klass if name_flag

      # "Api::V1::CategoryOperations::Create"
      # => "CategorOperations::Create"
      parts = qualified_name.split('::')
      target = parts[-2..-1]

      # TODO: Lookup Chopping of namespaces going ->
      # "Api::V1::CategoryOperations::Create"
      # => "V1::CategoryOperaitons::Create"

      # Lookup Chopping of namespaces going <-
      # "Api::V1::CategoryOperations::Create"
      # => "Api::CategoryOperations::Create"
      namespace = parts[0..-4]
      next_lookup = [namespace, target].reject(&:blank?).join('::')

      # recurse
      operation_lookup(next_lookup)
    end

    private

    # Decides if the constant exists or if we can travel any higher. Also,
    # validates the qualified_name in case it is blank.
    #
    # @param [String] qualified_name
    # @param [Symbol] sender The sender method
    #
    # @return [Array<Constant, Boolean>]
    def lookup_helper(qualified_name, sender)
      # Validate the name.
      name_flag = qualified_name.blank?
      return klass, name_flag if name_flag # return nil as the klass value

      # Return if the constant exists.
      klass = qualified_name.safe_constantize
      return klass, true if klass

      # Determine if we can travel up any higher.
      name_flag = if sender == :operation_lookup
                    qualified_name.scan(/::/).count <= 1
                  else
                    !qualified_name.include?('::')
                  end

      return klass, name_flag
    end
  end
end
