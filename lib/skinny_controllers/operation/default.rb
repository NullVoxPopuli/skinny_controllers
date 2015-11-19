module SkinnyControllers
  module Operation
    class Default < Base
      def run
        return unless allowed?

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
          @model.save
        elsif updating?
          model.update(model_params)
        elsif destroying?
          model.destroy
        end

        model
      end

      private

      def creating?
        params[:action] == 'create'
      end

      def updating?
        params[:action] == 'update'
      end

      def destroying?
        params[:action] == 'destroy'
      end
    end
  end
end
