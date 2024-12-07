class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  after_action :verify_authorized, unless: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, :keys => [:username])
    devise_parameter_sanitizer.permit(:account_update, :keys => [:avatar_url])
  end

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    
    redirect_back fallback_location: root_url
  end

  def after_sign_in_path_for(resource)
    if session[:save_plan_id]
      plan = Plan.find_by(id: session.delete(:save_plan_id))
      if plan
        resource.saved_plans.find_or_create_by(plan: plan)
        user_path(resource)
      else
        super
      end
    else
      super
    end
  end
end
