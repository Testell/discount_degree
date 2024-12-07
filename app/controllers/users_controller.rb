class UsersController < ApplicationController
  before_action :set_user, only: %i[show save_plan save_plan_prompt remove_saved_plan ]
  before_action :authenticate_user!, only: [:save_plan, :remove_saved_plan]
  skip_before_action :authenticate_user!, only: [:save_plan_prompt]
  skip_after_action :verify_authorized, only: [:save_plan_prompt]

  def show
    authorize @user
    @saved_plans = @user.plans
  end

  def save_plan_prompt
    session[:save_plan_id] = params[:plan_id]
    redirect_to new_user_session_path, notice: 'Please sign in to save the plan.'
  end

  def save_plan
    plan = Plan.find(params[:plan_id])
    @saved_plan = @user.saved_plans.build(plan: plan)
    authorize @saved_plan

    if @saved_plan.save
      redirect_to user_path(@user), notice: 'Plan was successfully saved.'
    else
      redirect_to plan_path(plan), alert: @saved_plan.errors.full_messages.to_sentence
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to plans_path, alert: 'Plan not found.'
  end

  def remove_saved_plan
    plan = Plan.find(params[:plan_id])
    @saved_plan = @user.saved_plans.find_by(plan: plan)
    authorize @saved_plan

    if @saved_plan&.destroy
      redirect_to user_path(@user), notice: 'Plan was successfully removed from your saved plans.'
    else
      redirect_to user_path(@user), alert: 'Unable to remove the plan.'
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to user_path(@user), alert: 'Plan not found.'
  end

  private

  def set_user
    if params[:username]
      @user = User.find_by!(username: params.fetch(:username))
    else
      @user = current_user
    end
  end
end
