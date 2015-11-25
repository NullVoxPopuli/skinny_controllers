module SkinnyControllers
  module Operation
    #
    # An example Operation may looy like
    #
    # module EventOperations
    #   class Read < SkinnyControllers::Policy::Base
    #     def run
    #       model if allowed?
    #     end
    #   end
    # end
    #
    # TODO: make the above the 'default' and not require to be defined
    class Base
      include ModelHelpers

      attr_accessor :params, :current_user, :authorized_via_parent

      def self.run(current_user, params)
        object = new(current_user, params)
        object.run
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

      def model_class
        @model_class ||= Lookup::Model.class_from_operation(self.class.name)
      end

      def model_name
        @object_type_name ||= Lookup::Model.name_from_operation(self.class.name)
      end

      def association_name_from_object
        model_name.tableize
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
        unless @policy_method_name
          method = Lookup::Policy.method_name_for_operation(self.class.name)
          has_method = policy_class.instance_methods.include?(method.to_sym)
          @policy_method_name = has_method ? method : 'default?'
        end

        @policy_method_name
      end

      # @return a new policy object and caches it
      def policy_for(object)
        @policy ||= policy_class.new(
          current_user,
          object,
          authorized_via_parent: authorized_via_parent)
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
