class PlansController < ApplicationController
  before_action { authorize(@plan || Plan) }
  before_action :set_plan, only: %i[show edit update destroy]
  before_action :set_degree, only: [:create]
  before_action :set_starting_school, only: [:create]

  def index
    @plans = Plan.all
  end

  def show
  end

  def new
    @plan = Plan.new
    @degrees = Degree.all
    @schools = School.where(school_type: "community_college")
  end

  def create
    ending_school = @degree.school

    generator = PlanServices::CheapestPlanGenerator.new(@degree, @starting_school, ending_school)
    generated_plan = generator.generate_cheapest_plan

    respond_to do |format|
      if generated_plan.present?
        @plan =
          @degree.plans.build(
            starting_school: @starting_school,
            ending_school: ending_school,
            total_cost: generated_plan[:total_cost],
            path: generated_plan[:path],
            term_assignments: generated_plan[:term_assignments]
          )

        if @plan.save
          format.html { redirect_to @plan, notice: "Plan was successfully created." }
          format.json { render :show, status: :created, location: @plan }
          format.js
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @plan.errors, status: :unprocessable_entity }
          format.js
        end
      else
        format.html { render :new, alert: "Failed to generate plan." }
        format.json do
          render json: { error: "Failed to generate plan." }, status: :unprocessable_entity
        end
        format.js
      end
    end
  rescue => e
    respond_to do |format|
      format.html { redirect_to new_plan_path, alert: "Error creating plan: #{e.message}" }
      format.json { render json: { error: e.message }, status: :unprocessable_entity }
      format.js
    end
  end

  def update
    respond_to do |format|
      if @plan.update(plan_params)
        format.html { redirect_to @plan, notice: "Plan was successfully updated." }
        format.json { render :show, status: :ok, location: @plan }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @plan.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @plan.destroy!

    respond_to do |format|
      format.html { redirect_to plans_url, notice: "Plan was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_plan
    @plan = Plan.find(params[:id])
  end

  def set_degree
    @degree = Degree.find(plan_params[:degree_id])
  end

  def set_starting_school
    @starting_school = School.find(plan_params[:starting_school_id])
  end

  def plan_params
    params.require(:plan).permit(:degree_id, :starting_school_id)
  end
end
