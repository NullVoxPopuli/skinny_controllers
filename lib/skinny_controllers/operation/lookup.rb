# frozen_string_literal: true
module SkinnyControllers
  module Operation
    class Lookup
      def initialize(controller_class, verb_for_action, options = {})
        @controller_class = controller_class
        @verb_for_action = verb_for_action
        @options = options
      end

      # PostsController
      # => PostOperations::Verb
      #
      # Api::V2::PostsController
      # => Api::V2::PostOperations::Verb
      def operation_class
        @operation_class ||= operation_name.safe_constantize
      end

      def operation_name
        @operation_name ||= resource_parts[-2]
      end

      def operation_namespace
        @operation_namespace ||= begin
          resource_parts.length > 2 ? resource_parts[0..-3].join('::') : ''
        end
      end

      # PostsController
      # => Posts, Controller
      #
      # Api::V2::PostsController
      # => Api, V2, Posts, Controller
      def resource_parts
        @resource_parts ||= controller_class_name.split(/::|Controller/)
      end

      def controller_class_name
        @controller_class_name ||= @controller_class.name
      end
    end
  end
end
