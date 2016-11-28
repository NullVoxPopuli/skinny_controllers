# frozen_string_literal: true
module SkinnyControllers
  class Lookup
    module Policy
      module_function

      # @param [String] name the name of the model
      # @return [Class] the policy class
      def class_from_model(name)
        policy_class_name = class_name_from_model(name)
        klass = policy_class_name.safe_constantize

        unless klass
          SkinnyControllers.logger.warn("#{policy_class_name} not found. Creating Default...")
        end

        klass || define_policy_class(policy_class_name)
      end

      def class_name_from_model(name)
        "#{name}#{SkinnyControllers.policy_suffix}"
      end

      def define_policy_class(name)
        default_policy = SkinnyControllers::Policy::Default
        namespace_klass = Object
        # if we are namespaced, we need to get / create the namespace if it doesn't exist already
        if name.include?('::')
          namespaces = name.split('::')
          namespace = namespaces[0..-2].join('::').presence
          namespace = namespace == name ? 'Object' : namespace
          if namespace.presence && namespace != name
            namespace_klass = Namespace.create_namespace(namespace)
          end
        end

        # naw remove the namespace from the name
        name = name.gsub(namespace_klass.name + '::', '')

        # finally, define the new policy class
        namespace_klass.const_set(name, default_policy.dup)
      end

      # @param [String] class_name name of the operation class
      def method_name_for_operation(class_name)
        class_name.demodulize.underscore + POLICY_METHOD_SUFFIX
      end
    end
  end
end
