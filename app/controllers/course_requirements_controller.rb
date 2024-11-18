class CourseRequirementsController < ApplicationController
  before_action :set_course_requirement, only: %i[ show edit update destroy ]

  # GET /course_requirements or /course_requirements.json
  def index
    @course_requirements = CourseRequirement.all
  end

  # GET /course_requirements/1 or /course_requirements/1.json
  def show
  end

  # GET /course_requirements/new
  def new
    @course_requirement = CourseRequirement.new
  end

  # GET /course_requirements/1/edit
  def edit
  end

  # POST /course_requirements or /course_requirements.json
  def create
    @course_requirement = CourseRequirement.new(course_requirement_params)

    respond_to do |format|
      if @course_requirement.save
        format.html { redirect_to course_requirement_url(@course_requirement), notice: "Course requirement was successfully created." }
        format.json { render :show, status: :created, location: @course_requirement }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @course_requirement.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /course_requirements/1 or /course_requirements/1.json
  def update
    respond_to do |format|
      if @course_requirement.update(course_requirement_params)
        format.html { redirect_to course_requirement_url(@course_requirement), notice: "Course requirement was successfully updated." }
        format.json { render :show, status: :ok, location: @course_requirement }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @course_requirement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /course_requirements/1 or /course_requirements/1.json
  def destroy
    @course_requirement.destroy!

    respond_to do |format|
      format.html { redirect_to course_requirements_url, notice: "Course requirement was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_course_requirement
      @course_requirement = CourseRequirement.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def course_requirement_params
      params.require(:course_requirement).permit(:course_id, :degree_requirement_id, :is_mandatory)
    end
end
