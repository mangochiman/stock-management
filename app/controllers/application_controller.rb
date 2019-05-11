class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token
  helper_method :current_user


  def current_user
    @current_user ||= User.find(session[:user]["user_id"]) if session[:user]
  end

  def authorize
    redirect_to ("/login") unless current_user
  end

end
