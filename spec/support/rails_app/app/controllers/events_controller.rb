class EventsController < ApplicationController
  include SkinnyControllers::Diet

  # GET /events
  #
  # renders an array of Events
  def index
    render json: model
  end

  # GET /events/1
  #
  # renders one event
  def show
    render json: model
  end

  # renders false, because the user doesn't have permission
  def throw_away
    render json: model
  end

end
