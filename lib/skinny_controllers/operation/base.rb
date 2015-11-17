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
        unless @object_class
          # "Namespace::Model" => "Model"
          model_name = object_type_of_interest.demodulize
          # "Model" => Model
          @object_class = model_name.constantize
        end

        @object_class
      end

      def object_type_of_interest
        unless @object_type_name
          # Namespace::ModelOperations::Verb
          klass_name = self.class.name
          # Namespace::ModelOperations::Verb => Namespace::ModelOperations
          namespace = klass_name.deconstantize
          # Namespace::ModelOperations => ModelOperations
          nested_namespace = namespace.demodulize
          # ModelOperations => Model
          @object_type_name = nested_namespace.gsub(SkinnyControllers.operations_suffix, '')
        end

        @object_type_name
      end

      def association_name_from_object
        object_type_of_interest.tableize
      end
    end
  end
end
