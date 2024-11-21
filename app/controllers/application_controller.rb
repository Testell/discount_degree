class ApplicationController < ActionController::Base
  skip_forgery_protection
  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :configure_permitted_parameters, if: :devise_controller?
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, :keys => [:username])

    devise_parameter_sanitizer.permit(:account_update, :keys => [:avatar_url])
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    
    redirect_back fallback_location: root_url
  end
end
