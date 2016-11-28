# frozen_string_literal: true
class EventSummariesController < ApplicationController
  include SkinnyControllers::Diet

  skinny_controllers_config model_class: Event

  def show
    render json: model
  end
end
