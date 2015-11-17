module SkinnyControllers
  module Diet
    extend ActiveSupport::Concern

    # TODO: what if we want multiple operations per action?
    #
    # @return an instance of the operation with default parameters
    def operation
      @operation ||= operation_class.new(current_user, params)
    end

    # Assumes the operation name from the controller name
    #
    # @example SomeObjectsController => Operation::SomeObject::Action
    #
    def operation_class
      model_name = model_name_from_controller
      klass_name = operation_class_from_model(model_name)
      klass = klass_name.safe_constantize
      klass || default_operation_class_for(model_name)
    end

    # dynamically creates a module for the model if it
    # isn't already defined
    def default_operation_class_for(model_name)
      default_operation = Operation::Default
      namespace = default_operation_namespace_for(model_name)

      default = "#{namespace.name}::Default".safe_constantize
      default || namespace.const_set('Default'.freeze, default_operation.dup)
    end

    def default_operation_namespace_for(model_name)
      desired_namespace = operation_namespace_from_model(model_name)

      parent_namespace = SkinnyControllers.operations_namespace
      namespace = "#{parent_namespace}::#{desired_namespace}".safe_constantize
      namespace || Object.const_set(desired_namespace, Module.new)
    end

    # abstraction for `operation.run`
    # useful when there is no logic needed for deciding what to
    # do with an operation or if there is no logic to decide which operation
    # to use
    def model
      @model ||= operation.run
    end

    private

    def operation_namespace_from_model(model_name)
      "#{model_name}#{SkinnyControllers::operations_suffix}"
    end

    # action name is inherited from ActionController::Base
    # http://www.rubydoc.info/docs/rails/2.3.8/ActionController%2FBase%3Aaction_name
    def verb_for_action
      SkinnyControllers.action_map[action_name] || SkinnyControllers.action_map['default']
    end

    def model_name_from_controller
      object_name = resource_name_from_controller.singularize
      # remove the namespace if one exists
      object_name.slice! controller_name_prefix
      object_name
    end

    def resource_name_from_controller
      controller_name = self.class.name
      controller_name.gsub('Controller', '')
    end

    def operation_class_from_model(model_name)
      prefix = SkinnyControllers.operations_namespace
      namespace = operation_namespace_from_model(model_name)
      "#{prefix}::#{namespace}::#{verb_for_action}"
    end

    def controller_name_prefix
      namespace = SkinnyControllers.controller_namespace || ''
      "#{namespace}::" if namespace
    end
  end
end
