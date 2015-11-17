module SkinnyControllers
  module ClassLookup
    module_function

    def model_name_to_operation_class(model_name, verb)
      # this namespace is '' by default
      prefix = SkinnyControllers.operations_namespace
      namespace = Transform.model_name_to_operation_namespace(model_name)
      "#{prefix}::#{namespace}::#{verb}"
    end

    def operation_from(controller, verb, model_name = nil)
      model_name ||= Transform.controller_to_model_name(controller)
      klass_name = ClassLookup.model_name_to_operation_class(model_name, verb)
      klass = klass_name.safe_constantize
      klass || default_operation_class_for(model_name)
    end

    # dynamically creates a module for the model if it
    # isn't already defined
    def default_operation_class_for(model_name)
      default_operation = Operation::Default
      namespace = ClassLookup.default_operation_namespace_for(model_name)

      default = "#{namespace.name}::Default".safe_constantize
      default || namespace.const_set('Default'.freeze, default_operation.dup)
    end

    def default_operation_namespace_for(model_name)
      desired_namespace = Transform.model_name_to_operation_namespace(model_name)

      parent_namespace = SkinnyControllers.operations_namespace
      namespace = "#{parent_namespace}::#{desired_namespace}".safe_constantize
      namespace || Object.const_set(desired_namespace, Module.new)
    end
  end
end
