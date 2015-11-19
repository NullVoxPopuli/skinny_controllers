class UsersController < ApplicationController
  include SkinnyControllers::Diet

  # GET /users/1
  def show
    render json: model
  end

  # DELETE /users/1
  def destroy
    render json: model
  end

end
