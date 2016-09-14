# frozen_string_literal: true
module SkinnyControllers
  module Operation
    #
    # An example Operation may looy like
    #
    # module EventOperations
    #   class Read < SkinnyControllers::Operation::Base
    #     def run
    #       model if allowed?
    #     end
    #   end
    # end
    #
    # TODO: make the above the 'default' and not require to be defined
    class Base
      include ModelHelpers

      attr_accessor :params, :current_user, :authorized_via_parent, :action, :params_for_action, :model_key

      class << self
        def run(current_user, params)
          object = new(current_user, params)
          object.run
        end

        # To support the shorthand ruby/block syntax
        # e.g.: MyOperation.()
        alias_method :call, :run
      end

      # To be overridden
      def run; end

      # To support teh shorthand ruby/block syntax
      # e.g.: MyOperation.new().()
      alias_method :call, :run

      # @param [Model] current_user the logged in user
      # @param [Hash] controller_params the params hash raw from the controller
      # @param [Hash] params_for_action optional params hash, generally the result of strong parameters
      # @param [string] action the current action on the controller
      def initialize(current_user, controller_params, params_for_action = nil, action = nil, model_key = nil)
        self.authorized_via_parent = false
        self.current_user = current_user
        self.action = action || controller_params[:action]
        self.params = controller_params
        self.params_for_action = params_for_action || controller_params
        self.model_key = model_key
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

      def model_class
        @model_class ||= Lookup::Model.class_from_operation(self.class.name)
      end

      def model_name
        @object_type_name ||= Lookup::Model.name_from_operation(self.class.name)
      end

      # @example model_name == Namespace::Item
      #  -> model_name.tableize == namespace/items
      #  -> split.last == items
      #
      # TODO: maybe make this configurable?
      def association_name_from_object
        model_name.tableize.split('/').last
      end

      # Takes the class name of self and converts it to a Policy class name
      #
      # @example In Operation::Event::Read, Policy::EventPolicy is returned
      def policy_class
        @policy_class ||= Lookup::Policy.class_from_model(model_name)
      end

      # Converts the class name to the method name to call on the policy
      #
      # @example Operation::Event::Read would become read?
      def policy_method_name
        @policy_method_name ||= Lookup::Policy.method_name_for_operation(self.class.name)
      end

      # @return a new policy object and caches it
      def policy_for(object)
        @policy ||= policy_class.new(
          current_user,
          object,
          authorized_via_parent: authorized_via_parent
        )
      end

      def allowed?
        allowed_for?(model)
      end

      # checks the policy
      def allowed_for?(object)
        policy_for(object).send(policy_method_name)
      end
    end
  end
end
