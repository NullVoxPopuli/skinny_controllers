module SkinnyControllers
  module ClassLookup
    module_function

    # @example 'ObjectOperations::Verb' => Object 
    # @return [Class] class based on the operation
    def model_from_operation(operation_name)

      # "Namespace::Model" => "Model"
      model_name = operation_to_model_name(operation_name)
      #object_type_of_interest.demodulize

      # "Model" => Model
      model_name.constantize
    end


    # @param [Controller] controller
    # @param [String] verb
    # @param [String] model_name optional
    # @return [Class] the class or default
    def operation_from(controller, verb, model_name = nil)
      model_name ||= Transform.controller_to_model_name(controller)
      klass_name = ClassLookup.model_name_to_operation_class(model_name, verb)
      klass = klass_name.safe_constantize
      klass || default_operation_class_for(model_name)
    end

    # dynamically creates a module for the model if it
    # isn't already defined
    # @return [Class] default operation class
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


    # @example 'Namespace::ModelOperation::Verb' => 'Model'
    # @return [String] the model name corresponding to the operation
    def operation_to_model_name(operation_name)
      # operation_name is something of the form:
      # Namespace::ModelOperations::Verb

      # Namespace::ModelOperations::Verb => Namespace::ModelOperations
      namespace = operation_name.deconstantize
      # Namespace::ModelOperations => ModelOperations
      nested_namespace = namespace.demodulize
      # ModelOperations => Model
      nested_namespace.gsub(SkinnyControllers.operations_suffix, '')
    end

    # @example 'Model', 'Verb' => [optional namespace]::ModelOperations::Verb
    #
    # @param [String] model_name name of the model
    # @param [String] the verb/action for the operation
    # @return [String] the operation based on the model name
    def model_name_to_operation_class(model_name, verb)
      # this namespace is '' by default
      prefix = SkinnyControllers.operations_namespace
      namespace = Transform.model_name_to_operation_namespace(model_name)
      "#{prefix}::#{namespace}::#{verb}"
    end

  end
end
