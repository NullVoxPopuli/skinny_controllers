# frozen_string_literal: true
module SkinnyControllers
  module Operation
    module ModelHelpers
      def model
        # TODO: not sure if multiple ids is a good idea here
        # if we don't have a(ny) id(s), get all of them
        @model ||= find_model
      end

      # hopefully this method is only ever called once per request
      # via the memoization in #model
      def find_model
        if params[:scope]
          model_from_scope
        elsif (key = params.keys.grep(/\_id$/)).present?
          # hopefully there is only ever one of these passed
          id = params[key.first]
          if params['id'].present?
            # single item / show
            model_from_parent(key.first, id, params['id'])
          else
            # list of items / index
            model_from_named_id(key.first, id)
          end
        elsif id_from_params
          model_from_id
        else
          model_from_params
        end
      end

      def sanitized_params
        keys = (model_class.column_names & params.keys)
        params.slice(*keys)
      end

      # TODO: add a way to use existing strong parameters methods
      def model_params
        # for mass-assignment, rails doesn't accept
        # stringified keys.
        # TODO: why did the params hash lose its indifferent access
        unless @model_params
          model_params = (params_for_action[model_param_name] || params_for_action)

          @model_params = model_params == params ? {} : model_params
        end

        @model_params
      end

      def model_param_name
        # model_key comes from Operation::Base
        model_key || model_name.underscore
      end

      # @param [Hash] scoped_params
      # @option scoped_params :type the class name
      # @option scoped_params :id the id of the class to look up
      def scoped_model(scoped_params)
        unless @scoped_model
          klass_name = scoped_params[:type]
          operation_class = Lookup::Operation.operation_of(klass_name, DefaultVerbs::Read)

          params = { id: scoped_params[:id] }
          operation = operation_class.new(
            current_user,
            params, params,
            'show', nil,
            model_class: klass_name.safe_constantize
          )

          @scoped_model = operation.run
          self.authorized_via_parent = !!@scoped_model
        end

        @scoped_model
      end

      def model_from_params
        model_class.where(sanitized_params)
      end

      def model_from_named_id(key, id)
        name = key.gsub(/_id$/, '')
        name = name.camelize
        association = model_from_scope(id: id, type: name)

        instance_exec(association, &SkinnyControllers.search_proc)
      end

      def model_from_scope(scope = params[:scope])
        if scoped = scoped_model(scope)
          association = association_name_from_object

          scoped.send(association)
        else
          raise ActiveRecord::RecordNotFound, "Parent object of type #{scope[:type]} not accessible"
        end
      end

      def model_from_parent(parent_class, parent_id, id)
        association = model_from_named_id(parent_class, parent_id)
        association.find(id)
      end

      def model_from_id
        model_class.find(id_from_params)
      end
    end
  end
end
