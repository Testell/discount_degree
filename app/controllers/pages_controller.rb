class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :plan_page, :generate_plan, :show_plan]
  skip_after_action :verify_authorized, only: [:home, :plan_page, :generate_plan, :show_plan]

  def home
  end

  def plan_page
    @degrees = Degree.all
    @community_colleges = School.where(school_type: 'community_college')
    @universities = School.where(school_type: 'university')
  end

  def generate_plan
    degree_id = params[:degree_id]
    starting_school_id = params[:starting_school_id]
    ending_school_id = params[:ending_school_id]
    @plan = Plan.find_by(
      degree_id: degree_id,
      starting_school_id: starting_school_id,
      ending_school_id: ending_school_id
    )

    if @plan
      redirect_to show_plan_path(plan_id: @plan.id)
    else
      flash[:alert] = 'No plan found for the selected options.'
      redirect_to plan_page_path
    end
  end

  def show_plan
    @plan = Plan.find(params[:plan_id])
  end
end
