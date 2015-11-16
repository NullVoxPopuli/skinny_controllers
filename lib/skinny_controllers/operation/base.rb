module SkinnyControllers
  module Operation
    #
    # An example Operation may looy like
    #
    # module Operations
    #   class Event::Read < Base
    #     def run
    #       model if allowed?
    #     end
    #   end
    # end
    #
    # TODO: make the above the 'default' and not require to be defined
    class Base
      POLICY_CLASS_PREFIX = 'Policy::'.freeze
      POLICY_CLASS_SUFFIX = 'Policy'.freeze
      POLICY_SUFFIX = '?'.freeze

      attr_accessor :params, :current_user, :authorized_via_parent

      class << self
        def run(current_user, params)
          new(current_user, params).run
        end
      end

      def initialize(current_user, params)
        self.current_user = current_user
        self.params = params
        self.authorized_via_parent = false
      end

      def id_from_params
        unless @id_from_params
          @id_from_params = params[:id]
          if filter = params[:filter]
            @id_from_params = filter[:id].split(',')
          end
        end

        @id_from_params
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

      def object_class
        @object_class ||= object_type_of_interest.demodulize.constantize
      end

      def object_type_of_interest
        @object_type_name ||= self.class.name.deconstantize.demodulize
      end

      def association_name_from_object
        object_type_of_interest.tableize
      end

      def policy_class
        @policy_class ||= (
          POLICY_CLASS_PREFIX +
          object_type_of_interest +
          POLICY_CLASS_SUFFIX
        ).constantize
      end

      def policy_name
        @policy_name ||= self.class.name.demodulize.downcase + POLICY_SUFFIX
      end

      def policy_for(object)
        @policy ||= policy_class.new(
          current_user,
          object,
          authorized_via_parent: authorized_via_parent)
      end

      def allowed?
        policy_for(model)
      end

      # checks the policy
      def allowed_for?(object)
        policy_for(object).send(policy_name)
      end
    end
  end
end
