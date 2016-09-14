# frozen_string_literal: true
class EventSummariesController < ApplicationController
  include SkinnyControllers::Diet
  self.model_class = Event

  def show
    render json: model
  end
end
