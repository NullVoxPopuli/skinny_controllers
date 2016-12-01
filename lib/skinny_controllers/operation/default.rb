# frozen_string_literal: true
module SkinnyControllers
  module Operation
    class Default < Base
      def run
        # Note that for explicitly defined operations,
        # There should be a different operation for each
        # action.
        #
        # e.g.:
        #  - EventOperations::Create
        #  - EventOperations::Update
        #  - EventOperations::Destroy
        if creating?
          @model = model_class.new(model_params)

          check_allowed!

          @model.save
          return @model
        end

        check_allowed!

        if updating?
          model.update(model_params)
        elsif destroying?
          model.destroy
        end

        model
      end

      private

      def creating?
        action == 'create'
      end

      def updating?
        action == 'update'
      end

      def destroying?
        action == 'destroy'
      end
    end
  end
end
