class SavedPlansController < ApplicationController
  before_action :set_saved_plan, only: [:show, :destroy]
  before_action :authenticate_user!

  def show
    authorize @saved_plan
  end

  def create
    @plan = Plan.find(params[:plan_id])
    @saved_plan = current_user.saved_plans.build(plan: @plan)
    authorize @saved_plan

    if @saved_plan.save
      redirect_to user_path(current_user), notice: 'Plan was successfully saved.'
    else
      redirect_to plan_path(@plan), alert: @saved_plan.errors.full_messages.to_sentence
    end
  end

  def destroy
    authorize @saved_plan
    @saved_plan.destroy
    redirect_to user_path(current_user), notice: 'Plan was successfully removed.'
  end

  private

  def set_saved_plan
    @saved_plan = SavedPlan.find(params[:id])
  end
end
