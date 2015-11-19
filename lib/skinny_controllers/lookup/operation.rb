module SkinnyControllers
  module Lookup
    module Operation
      module_function

      # @example ObjectOperations::Verb
      #
      # @param [String] model_name name of the model
      # @param [String] verb the verb/action for the operation
      # @return [Class] the operation based on the model name and the verb
      def operation_of(model_name, verb)
        klass_name = Lookup::Operation.name_from_model(model_name, verb)
        klass_name.safe_constantize
      end

      # @param [String] controller name of the controller class
      # @param [String] verb
      # @param [String] model_name optional
      # @return [Class] the class or default
      def from_controller(controller, verb, model_name = nil)
        model_name ||= Lookup::Controller.model_name(controller)
        klass = operation_of(model_name, verb)
        klass || default_operation_class_for(model_name)
      end

      # dynamically creates a module for the model if it
      # isn't already defined
      # @return [Class] default operation class
      def default_operation_class_for(model_name)
        default_operation = SkinnyControllers::Operation::Default
        namespace = Lookup::Operation.default_operation_namespace_for(model_name)

        default = "#{namespace.name}::Default".safe_constantize
        default || namespace.const_set('Default'.freeze, default_operation.dup)
      end

      # @return [Class] namespace for the default operation class
      def default_operation_namespace_for(model_name)
        desired_namespace = namespace_from_model(model_name)
        parent_namespace = SkinnyControllers.operations_namespace
        namespace = "#{parent_namespace}::#{desired_namespace}".safe_constantize
        namespace || Object.const_set(desired_namespace, Module.new)
      end

      # @example 'Object' => 'ObjectOperations'
      # @return [String] the operation namespace based on the model name
      def namespace_from_model(model_name)
        "#{model_name}#{SkinnyControllers.operations_suffix}"
      end

      # @example 'Model', 'Verb' => [optional namespace]::ModelOperations::Verb
      #
      # @param [String] model_name name of the model
      # @param [String] the verb/action for the operation
      # @return [String] the operation based on the model name
      def name_from_model(model_name, verb)
        # this namespace is '' by default
        prefix = SkinnyControllers.operations_namespace
        namespace = Lookup::Operation.namespace_from_model(model_name)
        "#{prefix}::#{namespace}::#{verb}"
      end
    end
  end
end
