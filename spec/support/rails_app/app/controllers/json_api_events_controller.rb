class JsonApiEventsController < ApplicationController
  include SkinnyControllers::Diet
  self.model_class = Event

  def index
    render json: model
  end

  def show
    render json: model
  end

  def create
    render json: model
  end

  def update
    render json: model
  end

  def destroy
    render json: model
  end

  def event_params
    # REST does not care for [:data][:id], it just uses :id
    params
      .require(:data)
      .require(:attributes)
      .permit(:name)
  end
end
