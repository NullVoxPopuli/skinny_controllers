module SkinnyControllers
  module Diet
    extend ActiveSupport::Concern

    included do
      #operation can be overridden
      class_attribute :operation_class
    end

    # @return an instance of the operation with default parameters
    def operation
      unless @operation
        klass = get_operation_class
        @operation = klass.new(current_user, params)
      end

      @operation
    end

    # Assumes the operation name from the controller name
    #
    # @example SomeObjectsController => Operation::SomeObject::Action
    #
    def get_operation_class
      unless self.class.operation_class
        model_name = model_name_from_controller
        klass_name = operation_class_from_model(model_name)
        klass = klass_name.safe_constantize
        self.class.operation_class = klass || Operation::Default
      end

      self.class.operation_class
    end


    # abstraction for `operation.run`
    # useful when there is no logic needed for deciding what to
    # do with an operation or if there is no logic to decide which operation
    # to use
    def model
      @model ||= operation.run
    end

    private

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
      resource_name = controller_name.gsub('Controller', '')
    end


    def operation_class_from_model(model_name)
      prefix = SkinnyControllers.operation_namespace
      "#{prefix}::#{model_name}::#{verb_for_action}"
    end

    def controller_name_prefix
      namespace = SkinnyControllers.controller_namespace || ''
      if namespace
        "#{namespace}::"
      end
    end

  end
end
