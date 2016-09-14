# frozen_string_literal: true
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
        klass = klass_name.safe_constantize
        klass || default_operation_class_for(model_name, verb)
      end

      # @param [String] controller name of the controller class
      # @param [String] verb
      # @param [String] model_name optional
      # @return [Class] the class or default
      def from_controller(controller, verb, model_name = nil)
        model_name ||= Lookup::Controller.model_name(controller)
        operation_of(model_name, verb)
      end

      # dynamically creates a module for the model if it
      # isn't already defined
      # @return [Class] default operation class
      # @param [String] verb
      def default_operation_class_for(model_name, verb)
        default_operation = SkinnyControllers::Operation::Default
        namespace = Lookup::Operation.default_operation_namespace_for(model_name)

        operation_class_name = "#{namespace.name}::#{verb}"
        default = operation_class_name.safe_constantize

        unless default
          SkinnyControllers.logger.warn("#{operation_class_name} not found. Creating default...")
        end

        default || namespace.const_set(verb, default_operation.dup)
      end

      # @return [Class] namespace for the default operation class
      def default_operation_namespace_for(model_name)
        # binding.pry
        desired_namespace = namespace_from_model(model_name)
        parent_namespace = SkinnyControllers.operations_namespace

        namespace_name = "#{parent_namespace}::#{desired_namespace}"
        namespace = namespace_name.safe_constantize

        unless namespace
          SkinnyControllers.logger.warn("#{namespace_name} not found. Creating...")
        end

        namespace || Namespace.create_namespace(desired_namespace)
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
