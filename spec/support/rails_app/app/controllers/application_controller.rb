class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # some fake helpers here
  def current_user=(user = User.last)
    @current_user = user
  end

  def current_user
    @current_user
  end
end
