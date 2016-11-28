# frozen_string_literal: true
class OtherItemsController < ApplicationController
  include SkinnyControllers::Diet

  skinny_controllers_config model_class: SuperItem::OtherItem,
                            model_params_key: 'other_item'

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
