class StrongParametersController < ApplicationController
  include SkinnyControllers::Diet

  self.model_class = Event

  def create
    render json: model
  end

  def update
    render json: model
  end

  def update_event_params
    params[:event].permit(:name)
  end

  def event_params
    params[:event].permit(:name)
  end
end
