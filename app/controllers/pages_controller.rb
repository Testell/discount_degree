class PagesController < ApplicationController
  def home
  end

  def plan_page
    @degrees = Degree.all
    @community_colleges = School.where(school_type: 'community_college')
    @universities = School.where(school_type: 'university')
  end

  def generate_plan
    # Retrieve the selected degree, starting school, and ending school from the form submission
    degree_id = params[:degree_id]
    starting_school_id = params[:starting_school_id]
    ending_school_id = params[:ending_school_id]

    # Find the plan that matches the selected options
    @plan = Plan.find_by(
      degree_id: degree_id,
      starting_school_id: starting_school_id,
      ending_school_id: ending_school_id
    )

    if @plan
      # Render the plan display view
      render 'show_plan'
    else
      # If the plan doesn't exist, redirect back with an error message
      flash[:alert] = 'No plan found for the selected options.'
      redirect_to plan_page_path
    end
  end
end

