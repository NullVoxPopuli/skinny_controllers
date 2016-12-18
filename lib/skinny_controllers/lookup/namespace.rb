# frozen_string_literal: true
module SkinnyControllers
  class Lookup
    module Namespace
      module_function

      # iterate through the namespaces until one doesn't exist, and create the rest
      def create_namespace(desired_namespace)
        if klass = desired_namespace.safe_constantize
          return klass
        end

        namespaces = desired_namespace.split('::')
        existing = []
        previous = Object

        namespaces.each do |namespace|
          current = (existing + [namespace]).join('::')
          begin
            Object.const_get(current)
          rescue NameError
            SkinnyControllers.logger.warn("Module #{namespace} not found, creating...")
            previous.const_set(namespace, Module.new)
          end

          existing << namespace
          previous = current.safe_constantize
        end

        SkinnyControllers.logger.warn("Namespace is nil. Attempted: '#{desired_namespace}'") unless previous

        previous
      end
    end
  end
end
