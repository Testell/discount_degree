class AdminCheapestPlanController < ApplicationController
  before_action :authenticate_user!
  before_action { authorize(:admin) }

  def create
    @degree = Degree.find(params[:id])
    starting_school_id = plan_params[:starting_school_id]
    Rails.logger.debug "Starting school ID: #{starting_school_id.inspect}"

    starting_school = School.find_by(id: starting_school_id)
    Rails.logger.debug "Starting school: #{starting_school.inspect}"

    ending_school = @degree.school  
    Rails.logger.debug "Ending school: #{ending_school.inspect}"

    if starting_school.nil?
      Rails.logger.error "Starting school not found with ID #{starting_school_id}"
      respond_to do |format|
        format.html { redirect_to degree_path(@degree), alert: 'Invalid starting school.' }
        format.json { render json: { error: 'Invalid starting school.' }, status: :unprocessable_entity }
        format.js   { render js: "alert('Invalid starting school.');" }
      end
      return
    end

    if ending_school.nil?
      Rails.logger.error "Ending school not found for degree ID #{@degree.id}"
      respond_to do |format|
        format.html { redirect_to degree_path(@degree), alert: 'Invalid ending school.' }
        format.json { render json: { error: 'Invalid ending school.' }, status: :unprocessable_entity }
        format.js   { render js: "alert('Invalid ending school.');" }
      end
      return
    end

    generator = PlanServices::CheapestPlanGenerator.new(@degree, starting_school, ending_school)
    generated_plan = generator.generate_cheapest_plan

    if generated_plan.present?
      @plan = @degree.plans.build(
        starting_school: starting_school,
        ending_school: ending_school,
        total_cost: generated_plan[:total_cost],
        path: generated_plan[:path],
        term_assignments: generated_plan[:term_assignments]
      )

      if @plan.save
        respond_to do |format|
          format.html { redirect_to degree_path(@degree), notice: 'Plan generated successfully.' }
          format.json { render :show, status: :created, location: @plan }
          format.js   # Optionally render create.js.erb for AJAX
        end
      else
        Rails.logger.error "Failed to save plan: #{@plan.errors.full_messages.join(', ')}"
        respond_to do |format|
          format.html { redirect_to degree_path(@degree), alert: 'Failed to save the generated plan.' }
          format.json { render json: { error: @plan.errors.full_messages }, status: :unprocessable_entity }
          format.js   { render js: "alert('Failed to save the generated plan.');" }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to degree_path(@degree), alert: 'Failed to generate plan.' }
        format.json { render json: { error: 'Failed to generate plan.' }, status: :unprocessable_entity }
        format.js   { render js: "alert('Failed to generate plan.');" }
      end
    end
  rescue => e
    Rails.logger.error "Error generating plan: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    respond_to do |format|
      format.html { redirect_to degree_path(@degree), alert: "Error generating plan: #{e.message}" }
      format.json { render json: { error: "Error generating plan: #{e.message}" }, status: :unprocessable_entity }
      format.js   { render js: "alert('Error generating plan: #{e.message}');" }
    end
  end

  private

  def plan_params
    params.require(:plan).permit(:starting_school_id)
  end
end
