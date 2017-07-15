# frozen_string_literal: true
class EventsController < ApplicationController
  include SkinnyControllers::Diet

  # respond_to :json

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

  # renders false, because the user doesn't have permission
  def throw_away
    render json: model
  end

  def load_hack
    # go-go-gadget rails autoload

    # rubocop:disable Lint/Void
    EventOperations
    EventPolicy
    # rubocop:enable Lint/Void

    render json: {}
  end

  def event_params
    params.permit!
    params
  end
end
