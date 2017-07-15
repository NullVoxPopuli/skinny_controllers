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

      attr_accessor :params, :current_user, :authorized_via_parent,
        :action, :params_for_action, :model_key,
        :association_name, :options,
        :_lookup

      class << self
        def run(*args)
          object = new(*args)
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

      # TODO: too many *optional* parameters. Group into options hash
      #
      # @param [Model] current_user the logged in user
      # @param [Hash] controller_params the params hash raw from the controller
      # @param [Hash] params_for_action optional params hash, generally the result of strong parameters
      # @param [string] action the current action on the controller
      def initialize(current_user,
        controller_params, params_for_action = nil,
        action = nil,
        lookup = nil,
        options = {})

        self.authorized_via_parent = false
        self.current_user = current_user
        self.action = action || controller_params[:action]
        self.params = controller_params
        self.params_for_action = params_for_action || controller_params

        self._lookup = lookup
        self.options = options
        self.model_key = options[:model_params_key]
        self.association_name = options[:association_name]
      end

      def lookup
        @lookup ||= begin
          _lookup || Lookup.from_operation(
            operation_class: self.class,
            model_class: options[:model_class]
          )
        end
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

      delegate :model_class, :model_name,
        :policy_class, :policy_method_name,
        to: :lookup

      # @example model_name == Namespace::Item
      #  -> model_name.tableize == namespace/items
      #  -> split.last == items
      #
      # TODO: maybe make this configurable?
      def association_name_from_object
        association_name || model_name.tableize.split('/').last
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

      def check_allowed!(*args)
        raise DeniedByPolicy.new(*args.presence || action) unless allowed?
      end

      # checks the policy
      def allowed_for?(object)
        policy_for(object).send(policy_method_name)
      end
    end
  end
end
