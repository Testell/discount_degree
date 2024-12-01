class AdminCheapestPlanController < ApplicationController
  before_action :authenticate_user!
    before_action :authorize_admin

    def new
      @degree = Degree.find(params[:degree_id])
      @starting_schools = School.where(school_type: 'community_college')
      @ending_schools = School.where(school_type: 'university')
    end

    def create
      @degree = Degree.find(params[:degree_id])
      starting_school = School.find(plan_params[:starting_school_id])
      ending_school_id = plan_params[:ending_school_id]

      if ending_school_id.present?
        ending_school = School.find(ending_school_id)
        generator = PlanServices::CheapestPlanGenerator.new(@degree, starting_school, ending_school)
      else
        generator = PlanServices::CheapestPlanGenerator.new(@degree, starting_school, nil)
      end

      generator.generate_cheapest_plan

      redirect_to admin_degree_path(@degree), notice: 'Plans generated successfully.'
    end

    private

    def authorize_admin
      redirect_to root_path, alert: 'Access denied.' unless current_user.admin?
    end

    def plan_params
      params.require(:plan).permit(:starting_school_id, :ending_school_id)
    end
  end
end
