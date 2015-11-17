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
          elsif key = params.keys.grep(/_id$/)
            # hopefully there is only ever one of these passed
            model_from_named_id(key.first)
          else
            model_from_params
          end
      end

      def scoped_model(scoped_params)
        unless @scoped_model
          klass_name = scoped_params[:type]
          operation_name = "Operations::#{klass_name}::Read"
          operation = operation_name.constantize.new(current_user, id: scoped_params[:id])
          @scoped_model = operation.run
          self.authorized_via_parent = !!@scoped_model
        end

        @scoped_model
      end

      def model_from_params
        object_class.where(params).accessible_to(current_user)
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
