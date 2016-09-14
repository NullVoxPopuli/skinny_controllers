# frozen_string_literal: true
module SkinnyControllers
  module Diet
    extend ActiveSupport::Concern

    included do
      class << self
        attr_accessor :model_class
        attr_accessor :model_key
      end
    end

    # TODO: what if we want multiple operations per action?
    #
    # @return an instance of the operation with default parameters
    def operation
      @operation ||= operation_class.new(
        current_user,
        params, params_for_action,
        action_name, self.class.model_key
      )
    end

    # Assumes the operation name from the controller name
    #
    # @example SomeObjectsController => Operation::SomeObject::Action
    # @return [Class] the operation class for the model and verb
    def operation_class
      Lookup::Operation.from_controller(self.class.name, verb_for_action, self.class.model_class)
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

    # In order of most specific, to least specific:
    # - {action}_{model_name}_params
    # - {model_name}_params
    # - params
    #
    # It's recommended to use whitelisted strong parameters on
    # actions such as create and update
    #
    # @return the whitelisted strong parameters object
    def params_for_action
      return {} if action_name == 'destroy'

      key = self.class.model_key
      # model_class should be a class
      klass = self.class.model_class

      model_key =
        if key.present?
          key
        elsif klass
          klass.name.underscore
        else
          Lookup::Controller.model_name(self.class.name).underscore
        end

      action_params_method = "#{action_name}_#{model_key}_params"
      model_params_method = "#{model_key}_params"

      if respond_to? action_params_method, true
        send(action_params_method)
      elsif respond_to? model_params_method, true
        send(model_params_method)
      else
        params
      end
    end

    # action name is inherited from ActionController::Base
    # http://www.rubydoc.info/docs/rails/2.3.8/ActionController%2FBase%3Aaction_name

    def verb_for_action
      SkinnyControllers.action_map[action_name] ||
        (action_name && action_name.classify) ||
        SkinnyControllers.action_map['default']
    end
  end
end
