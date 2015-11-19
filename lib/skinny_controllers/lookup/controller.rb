module SkinnyControllers
  module Lookup
    module Controller
      module_function

      # @example ObjectsController => Objects
      # @return [String] the resource name
      def resource_name(controller_name)
        name = controller_name.gsub('Controller', '')
        # remove the namespace if one exists
        name.slice! namespace
        name
      end

      # @example <ObjectsContreller> => Object
      # @return [String] name of the class of the model
      def model_name(controller)
        resource_name = Controller.resource_name(controller)
        # Convert Resources to Resource
        resource_name.singularize
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
      def namespace
        namespace = SkinnyControllers.controller_namespace || ''
        "#{namespace}::" if namespace
      end
    end
  end
end
