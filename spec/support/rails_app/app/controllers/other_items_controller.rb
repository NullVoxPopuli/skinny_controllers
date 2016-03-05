class OtherItemsController < ApplicationController
  include SkinnyControllers::Diet
  self.model_class = SuperItem::OtherItem
  self.model_key = 'other_item'

  def index
    # TODO: make this implicit
    model = operation_class.new(current_user, params, index_params).run
    render json: model, include: params[:include]
  end

  # GET /users/1
  def show
    render json: model
  end

  # DELETE /users/1
  def destroy
    render json: model
  end

  def create
    render json: model
  end

  def index_params
    params[:filter] ? params : params.require(:super_item_id)
  end
end
