# required gems
require 'active_support'
require 'active_support/core_ext/class'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/try'
require 'active_support/core_ext/string/inflections'

# files for this gem
require 'skinny_controllers/default_verbs'
require 'skinny_controllers/policy/base'
require 'skinny_controllers/operation/policy_helpers'
require 'skinny_controllers/operation/model_helpers'
require 'skinny_controllers/operation/base'
require 'skinny_controllers/operation/default'
require 'skinny_controllers/diet'
require 'skinny_controllers/version'

module SkinnyControllers
  # Tells the Diet what namespace of the controller
  # isn't going to be part of the model name
  #
  # @example
  #  # config/initializers/skinny_controllers.rb
  #  SkinnyControllers.controller_namespace = 'API'
  #  # 'API::' would be removed from 'API::Namespace::ObjectNamesController'
  cattr_accessor :controller_namespace

  #
  cattr_accessor :operation_namespace do
    'Operation'.freeze
  end

  cattr_accessor :allow_by_default do
    true
  end

  # the diet uses ActionController::Base's
  # `action_name` method to get the current action.
  # From that action, we map what verb we want to use for our operation
  #
  # If an action is not be listed, the action name will be
  # manipulated to fit the verb naming convention.
  #
  # @example POST controller#send_receipt will use 'SendReceipt' for the verb
  cattr_accessor :action_map do
    {
      'default'.freeze => DefaultVerbs::Read,
      'create'.freeze => DefaultVerbs::Create,
      'index'.freeze => DefaultVerbs::ReadAll,
      'destroy'.freeze => DefaultVerbs::Delete,
      'update'.freeze => DefaultVerbs::Update
    }
  end
end
