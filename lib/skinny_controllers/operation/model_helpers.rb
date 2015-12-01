module SkinnyControllers
  module Operation
    module ModelHelpers
      def model
        # TODO: not sure if multiple ids is a good idea here
        # if we don't have a(ny) id(s), get all of them
        @model ||=
          if params[:scope]
            model_from_scope
          elsif (key = params.keys.grep(/\_id$/)).present?
            # hopefully there is only ever one of these passed
            id = params[key.first]
            model_from_named_id(key.first, id)
          elsif id_from_params
            model_from_id
          else
            model_from_params
          end
      end

      def sanitized_params
        keys = (model_class.column_names & params.keys)
        params.slice(*keys).symbolize_keys
      end

      # TODO: add a way to use existing strong parameters methods
      def model_params
        # for mass-assignment, rails doesn't accept
        # stringified keys.
        # TODO: why did the params hash lose its indifferent access
        @model_params ||= param_parser.model_params.symbolize_keys
      end

      def param_parser
        unless @param_parser
          @param_parser =
            if SkinnyControllers.params_format == :json
              Params::Json.new(params, model_param_name)
            else
              Params::JsonApi.new(params, model_param_name)
            end
        end

        @param_parser
      end

      def model_param_name
        model_name.underscore
      end

      def scoped_model(scoped_params)
        unless @scoped_model
          klass_name = scoped_params[:type]
          operation_class = Lookup::Operation.operation_of(klass_name, DefaultVerbs::Read)
          operation = operation_class.new(current_user, id: scoped_params[:id])
          @scoped_model = operation.run
          self.authorized_via_parent = !!@scoped_model
        end

        @scoped_model
      end

      def model_from_params
        ar_proxy = model_class.where(sanitized_params)

        if ar_proxy.respond_to? SkinnyControllers.accessible_to_scope
          # It's better to filter in sql, than in the app, so if there is
          # a way to do the filtering in active query, do that. This will help
          # mitigate n+1 query scenarios
          return ar_proxy.send(SkinnyControllers.accessible_to_scope, current_user)
        end

        ar_proxy
      end

      def model_from_named_id(key, id)
        name, _id = key.split('_')
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
        model_class.find(id_from_params)
      end
    end
  end
end
