module SkinnyControllers
  module Transform
    module_function

    # @example 'Object' => 'ObjectOperations'
    # @return [String] the operation namespace based on the model name
    def model_name_to_operation_namespace(model_name)
      "#{model_name}#{SkinnyControllers::operations_suffix}"
    end

    # @example ObjectsController => Objects
    # @return [String] the resource name
    def controller_name_to_resource_name(controller_name)
      controller_name.gsub('Controller', '')
    end

    # @example <ObjectsContreller> => Object
    # @return [String] name of the class of the model
    def controller_to_model_name(controller)
      resource_name = controller_name_to_resource_name(controller.class.name)
      # Convert Resources to Resource
      object_name = resource_name_from_controller.singularize
      # remove the namespace if one exists
      object_name.slice! controller_name_prefix
      object_name
    end

    # TODO: add option to configure this per controller
    #
    # @example
    #   If the controller_namespace is specified as 'API', and
    #   the controller name is API::ObjectsController,
    #   API:: will be ignored from the name. However if the
    #   controller_namespace is left blank, API will be assumed to
    #   be a part of the model's namespace.
    # @return [String] the optional namespace of all controllers
    def controller_namespace
      namespace = SkinnyControllers.controller_namespace || ''
      "#{namespace}::" if namespace
    end


  end
end
