module SkinnyControllers
  module Operation
    module ModelHelpers
      def model
        # TODO: not sure if multiple ids is a good idea here
        # if we don't have a(ny) id(s), get all of them


        @model ||=
          if id_from_params
            model_from_id
          elsif params[:scope]
            model_from_scope
          elsif (key = params.keys.grep(/\_id$/)).present?
            # hopefully there is only ever one of these passed
            model_from_named_id(key.first)
          else
            model_from_params
          end
      end

      def sanitized_params
        keys = (object_class.column_names & params.keys)
        params.slice(*keys).symbolize_keys
      end

      def scoped_model(scoped_params)
        unless @scoped_model
          klass_name = scoped_params[:type]
          operation_name = operation_for(klass_name, 'Read'.freeze)
          operation = operation_name.constantize.new(current_user, id: scoped_params[:id])
          @scoped_model = operation.run
          self.authorized_via_parent = !!@scoped_model
        end

        @scoped_model
      end

      def operation_for(klass_name, verb)
        operations_class_namespace +
        klass_name +
        SkinnyControllers.operations_suffix +
        "::#{verb}"
      end

      def operations_class_namespace
        namespace = SkinnyControllers.policies_namespace
        "#{namespace}::" if namespace
      end

      def model_from_params
        ar_proxy = object_class.where(sanitized_params)

        if ar_proxy.respond_to? SkinnyControllers.accessible_to_scope
          return ar_proxy.accessible_to(current_user)
        end

        ar_proxy
      end

      def model_from_named_id(key)
        name, id = key.split('_')
        name = name.camelize
        model_from_scope(
          id: id,
          type: name
        )
      end

      def model_from_scope(scope = params[:scope])
        if scoped = scoped_model(scope)
          association = association_name_from_object
          scoped.send(association)
        else
          fail "Parent object of type #{scope[:type]} not accessible"
        end
      end

      def model_from_id
        object_class.find(id_from_params)
      end
    end
  end
end
