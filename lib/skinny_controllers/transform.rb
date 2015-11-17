module SkinnyControllers
  module Transform
    module_function

    def model_name_to_operation_namespace(model_name)
      "#{model_name}#{SkinnyControllers::operations_suffix}"
    end

    def controller_name_to_resource_name(controller_name)
      controller_name.gsub('Controller', '')
    end

    def controller_to_model_name(controller)
      resource_name = controller_name_to_resource_name(controller.class.name)
      # Convert Resources to Resource
      object_name = resource_name_from_controller.singularize
      # remove the namespace if one exists
      object_name.slice! controller_name_prefix
      object_name
    end

    def controller_namespace
      namespace = SkinnyControllers.controller_namespace || ''
      "#{namespace}::" if namespace
    end


  end
end
