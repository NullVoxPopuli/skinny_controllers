class NoOperationsController < ApplicationController
  include SkinnyControllers::Diet
  def show
    render json: model
  end
end
