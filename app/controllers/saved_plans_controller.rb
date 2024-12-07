class SavedPlansController < ApplicationController
  before_action :authenticate_user!
  before_action :set_plan, only: [:create]

  def create
    @saved_plan = current_user.saved_plans.build(plan: @plan)
    authorize @saved_plan
    if @saved_plan.save
      redirect_to user_path(current_user), notice: 'Plan was successfully saved.'
    else
      redirect_to plan_path(@plan), alert: @saved_plan.errors.full_messages.to_sentence
    end
  end

  private

  def set_plan
    @plan = Plan.find(params[:plan_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to plans_path, alert: 'Plan not found.'
  end
end
