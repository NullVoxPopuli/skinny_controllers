module SkinnyControllers
  module Diet
    extend ActiveSupport::Concern

    included do
      cattr_accessor :model_class
    end

    # TODO: what if we want multiple operations per action?
    #
    # @return an instance of the operation with default parameters
    def operation
      @operation ||= operation_class.new(current_user, params)
    end

    # Assumes the operation name from the controller name
    #
    # @example SomeObjectsController => Operation::SomeObject::Action
    # @return [Class] the operation class for the model and verb
    def operation_class
      Lookup::Operation.from_controller(self.class.name, verb_for_action, model_class)
    end

    # abstraction for `operation.run`
    # useful when there is no logic needed for deciding what to
    # do with an operation or if there is no logic to decide which operation
    # to use
    #
    # @return [ActiveRecord::Base] the model
    def model
      @model ||= operation.run
    end

    private

    # action name is inherited from ActionController::Base
    # http://www.rubydoc.info/docs/rails/2.3.8/ActionController%2FBase%3Aaction_name
    def verb_for_action
      SkinnyControllers.action_map[action_name] || SkinnyControllers.action_map['default']
    end
  end
end
