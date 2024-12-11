class AdminCheapestPlanController < ApplicationController
  before_action { authorize(:admin) }

  def create
    @degree = Degree.find(params[:id])
    starting_school_id = plan_params[:starting_school_id]

    starting_school = School.find_by(id: starting_school_id)

    ending_school = @degree.school

    if starting_school.nil?
      respond_to do |format|
        format.html { redirect_to degree_path(@degree), alert: "Invalid starting school." }
        format.json do
          render json: { error: "Invalid starting school." }, status: :unprocessable_entity
        end
        format.js { render js: "alert('Invalid starting school.');" }
      end
      return
    end

    if ending_school.nil?
      respond_to do |format|
        format.html { redirect_to degree_path(@degree), alert: "Invalid ending school." }
        format.json do
          render json: { error: "Invalid ending school." }, status: :unprocessable_entity
        end
        format.js { render js: "alert('Invalid ending school.');" }
      end
      return
    end

    generator = PlanServices::CheapestPlanGenerator.new(@degree, starting_school, ending_school)
    generated_plan = generator.generate_cheapest_plan

    if generated_plan.present?
      @plan =
        @degree.plans.build(
          starting_school: starting_school,
          ending_school: ending_school,
          total_cost: generated_plan[:total_cost],
          path: generated_plan[:path],
          term_assignments: generated_plan[:term_assignments]
        )

      if @plan.save
        respond_to do |format|
          format.html { redirect_to degree_path(@degree), notice: "Plan generated successfully." }
          format.json { render :show, status: :created, location: @plan }
          format.js
        end
      else
        respond_to do |format|
          format.html do
            redirect_to degree_path(@degree), alert: "Failed to save the generated plan."
          end
          format.json do
            render json: { error: @plan.errors.full_messages }, status: :unprocessable_entity
          end
          format.js { render js: "alert('Failed to save the generated plan.');" }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to degree_path(@degree), alert: "Failed to generate plan." }
        format.json do
          render json: { error: "Failed to generate plan." }, status: :unprocessable_entity
        end
        format.js { render js: "alert('Failed to generate plan.');" }
      end
    end
  rescue => e
    respond_to do |format|
      format.html { redirect_to degree_path(@degree), alert: "Error generating plan: #{e.message}" }
      format.json do
        render json: { error: "Error generating plan: #{e.message}" }, status: :unprocessable_entity
      end
      format.js { render js: "alert('Error generating plan: #{e.message}');" }
    end
  end

  private

  def plan_params
    params.require(:plan).permit(:starting_school_id)
  end
end
