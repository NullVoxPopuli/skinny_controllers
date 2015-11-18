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
      include PolicyHelpers
      include ModelHelpers

      attr_accessor :params, :current_user, :authorized_via_parent

      def self.run(current_user, params)
        object = self.new(current_user, params)
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

      def object_class
        @object_class ||= ClassLookup.model_from_operation(self.class.name)
      end

      def object_type_of_interest
        @object_type_name ||= ClassLookup.operation_to_model_name(self.class.name)
      end

      def association_name_from_object
        object_type_of_interest.tableize
      end
    end
  end
end
