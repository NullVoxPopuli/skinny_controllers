# frozen_string_literal: true
module SkinnyControllers
  # This class provides a way to determine all names / classes of operations
  # and policies based on he given information.
  #
  # The class methods show what is required for each scenario
  class Lookup
    include EnsureExistence
    include Policy

    class << self
      def from_controller(controller_class:, verb:, model_class:)
        Lookup.new(
          controller_class_name: controller_class.name,
          verb:                  verb,
          model_class:           model_class
        )
      end

      def from_operation(operation_class:)
        qualified_name = operation_class.name
        parts = qualified_name.split('::')
        operation_name = parts[-2]
        operation_parts = operation_name.split(SkinnyControllers.operations_suffix)

        Lookup.new(
          verb:            parts.last,
          # namespace:       parts[0..-3],
          operation_name:  operation_name,
          operation_class: operation_class,
          model_name:      operation_parts.first,
          namespace:       qualified_name.deconstantize.deconstantize
        )
      end
    end

    # @param [Hash] args - all possible parameters
    # - @option [String] controller_class_name
    # - @option [Class] controller_class
    # - @option [String] verb
    # - @option [String] operation_name
    # - @option [String] model_name
    # - @option [Class] model_class
    # - @option [Hash] options
    def initialize(args = {})
      @controller_class_name = args[:controller_class_name]
      @controller_class = args[:controller_class]
      @verb_for_action = args[:verb]
      @operation_name = args[:operation_name]
      @operation_class = args[:operation_class]
      @model_name = args[:model_name]
      @namespace = args[:namespace]
      @model_class = args[:model_class]
      @policy_method_name = args[:policy_method_name]
      @options = args[:options] || {}
    end

    # PostsController
    # => PostOperations::Verb
    #
    # Api::V2::PostsController
    # => Api::V2::PostOperations::Verb
    def operation_class
      @operation_class ||= begin
        ensure_namespace!(operation_namespace) if operation_namespace.present?
        ensure_operation_class!(namespaced_operation_name)
      end
    end

    def policy_class
      @policy_class ||= begin
        ensure_namespace!(namespace) if namespace.present?
        ensure_policy_class!(namespaced_policy_name)
      end
    end

    def policy_method_name
      @policy_method_name ||= @verb_for_action.underscore + POLICY_METHOD_SUFFIX
    end

    def model_class
      @model_class ||= @options[:model_class] || model_name.safe_constantize
    end

    def model_name
      @model_name ||= @model_class.try(:name) || resource_parts[-1].singularize
    end

    # @return [String] name of the supposed operation class
    def namespaced_operation_name
      @namespaced_operation_name ||= [
        operation_namespace,
        @verb_for_action
      ].reject(&:blank?).join('::')
    end

    def namespaced_policy_name
      @namespaced_policy_name ||= [
        namespace,
        "#{model_name}#{SkinnyControllers.policy_suffix}"
      ].reject(&:blank?).join('::')
    end

    def operation_namespace
      @operation_namespace ||= [
        namespace,
        operation_name
      ].reject(&:blank?).join('::')
    end

    def operation_name
      @operation_name ||= "#{model_name}#{SkinnyControllers.operations_suffix}"
    end

    # @return [String] the namespace
    def namespace
      @namespace ||= begin
        resource_parts.length > 1 ? resource_parts[0..-2].join('::') : ''
      end
    end

    # PostsController
    # => Posts
    #
    # Api::V2::PostsController
    # => Api, V2, Posts
    def resource_parts
      @resource_parts ||= controller_class_name.split(/::|Controller/)
    end

    def controller_class_name
      @controller_class_name ||= @controller_class.name
    end
  end
end
