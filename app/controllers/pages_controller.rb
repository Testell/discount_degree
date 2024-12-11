class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[home plan_page generate_plan show_plan]
  skip_after_action :verify_authorized, only: %i[home plan_page generate_plan show_plan]

  def home
  end

  def plan_page
    @degrees = Degree.all
    @community_colleges = School.where(school_type: "community_college")
    @universities = School.where(id: Plan.select(:ending_school_id).distinct)
  end

  def generate_plan
    degree_id = params[:degree_id]
    starting_school_id = params[:starting_school_id]
    ending_school_id = params[:ending_school_id]

    @plans =
      Plan.where(
        degree_id: degree_id,
        starting_school_id: starting_school_id,
        ending_school_id: ending_school_id
      ).order(total_cost: :desc)

    if @plans.any?
      redirect_to show_plan_path(plan_id: @plans.first.id, alternate_plan_id: @plans.second&.id)
    else
      flash[:alert] = "No plans found for the selected options."
      redirect_to plan_page_path
    end
  end

  def show_plan
    @plan = Plan.find(params[:plan_id])
    @alternate_plan = Plan.find(params[:alternate_plan_id]) if params[:alternate_plan_id]
    @showing_full_time = params[:show_full_time] == "true"

    respond_to do |format|
      format.html
      format.js
    end
  end
end
