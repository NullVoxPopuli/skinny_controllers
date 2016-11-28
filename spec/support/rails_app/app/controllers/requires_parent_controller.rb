# frozen_string_literal: true
class RequiresParentController < ApplicationController
  include SkinnyControllers::Diet

  skinny_controllers_config model_class: Discount,
                            parent_class: Event,
                            association_name: :discounts


  def index
    model = create_operation(user: current_user, params_for_action: index_params).run
    render json: model, include: params[:include]
  end

  def show
    model = create_operation(user: current_user, params_for_action: index_params).run
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
