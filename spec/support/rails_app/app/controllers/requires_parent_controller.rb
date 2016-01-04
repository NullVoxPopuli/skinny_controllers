class RequiresParentController < ApplicationController
  include SkinnyControllers::Diet
  self.model_class = Discount


  def index
    model = operation_class.new(current_user, params, index_params).run
    render json: model, include: params[:include]
  end

  def show
    render json: model
  end

  private

  def index_params
    params.require(:event_id)
  end

end
