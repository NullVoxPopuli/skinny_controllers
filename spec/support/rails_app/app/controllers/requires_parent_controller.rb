# frozen_string_literal: true
class RequiresParentController < ApplicationController
  include SkinnyControllers::Diet
  # self.model_class = Discount
  # self.association_name = :discounts

  skinny_controllers_config model_class: Discount,
                            parent_class: Event,
                            association_name: :discounts


  def index
    model = operation_class.new(current_user, params, index_params).run
    render json: model, include: params[:include]
  end

  def show
    model = operation_class.new(current_user, params, index_params).run
    render json: model, include: params[:include]
  end

  private

  def index_params
    params.require(:event_id)
  end

  def show_params
    params.require(:event_id)
  end
end
