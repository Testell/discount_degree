class CourseRequirementsController < ApplicationController
  before_action { authorize(@course_requirement || CourseRequirement) }
  before_action :set_course_requirement, only: %i[destroy]
  before_action :set_degree_requirement, only: %i[create]

  def index
    @course_requirements = CourseRequirement.all
  end

  def show
    @course_requirement = CourseRequirement.find(params[:id])
  end

  def new
    @course_requirement = CourseRequirement.new
  end

  def edit
  end

  def create
    @course_requirement = @degree_requirement.course_requirements.build(course_requirement_params)

    respond_to do |format|
      if @course_requirement.save
        format.turbo_stream
        format.html do
          redirect_to degree_requirement_path(@degree_requirement),
                      notice: "Course requirement was successfully created."
        end
        format.json { render :show, status: :created, location: @course_requirement }
      else
        format.html do
          redirect_to degree_requirement_path(@degree_requirement),
                      alert: "Unable to create course requirement."
        end
        format.json { render json: @course_requirement.errors, status: :unprocessable_entity }
        format.turbo_stream do
          render turbo_stream:
                   turbo_stream.replace(
                     "new_course_requirement_form",
                     partial: "form",
                     locals: {
                       degree_requirement: @degree_requirement,
                       course_requirement: @course_requirement
                     }
                   )
        end
      end
    end
  end

  def update
    respond_to do |format|
      if @course_requirement.update(course_requirement_params)
        format.html do
          redirect_to course_requirement_url(@course_requirement),
                      notice: "Course requirement was successfully updated."
        end
        format.json { render :show, status: :ok, location: @course_requirement }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @course_requirement.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @degree_requirement = @course_requirement.degree_requirement
    @course_requirement.destroy!

    respond_to do |format|
      format.html do
        redirect_to degree_requirement_path(@degree_requirement),
                    notice: "Course requirement was successfully destroyed."
      end
      format.turbo_stream do
        @course_requirements = @degree_requirement.course_requirements.includes(:course)
        render :destroy
      end
    end
  end

  private

  def set_course_requirement
    @course_requirement = CourseRequirement.find(params[:id])
  end

  def set_degree_requirement
    @degree_requirement = DegreeRequirement.find(params[:degree_requirement_id])
  end

  def course_requirement_params
    params.require(:course_requirement).permit(:course_id, :is_mandatory)
  end
end
