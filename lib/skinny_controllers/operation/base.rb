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
      include PolicyHelpers
      include ModelHelpers

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

      def object_class
        @object_class ||= object_type_of_interest.demodulize.constantize
      end

      def object_type_of_interest
        @object_type_name ||= self.class.name.deconstantize.demodulize
      end

      def association_name_from_object
        object_type_of_interest.tableize
      end
    end
  end
end
