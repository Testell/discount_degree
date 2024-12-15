class DegreeRequirementsController < ApplicationController
  before_action { authorize(@degree_requirement || DegreeRequirement) }
  before_action :set_degree_requirement, only: %i[show edit update destroy]
  before_action :set_degree, only: [:create]

  def index
    @degree_requirements = DegreeRequirement.all
  end

  def show
    @course_requirement = CourseRequirement.new(degree_requirement: @degree_requirement)
  end

  def new
    @degree_requirement = DegreeRequirement.new
  end

  def edit
  end

  def create
    @degree_requirement = @degree.degree_requirements.build(degree_requirement_params)

    respond_to do |format|
      if @degree_requirement.save
        format.html do
          redirect_to degree_path(@degree), notice: "Degree requirement was successfully created."
        end
        format.json { render :show, status: :created, location: @degree_requirement }
        format.js
      else
        format.html do
          redirect_to degree_path(@degree), alert: "Unable to create degree requirement."
        end
        format.json { render json: @degree_requirement.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @degree_requirement.update(degree_requirement_params)
      redirect_to degree_requirement_path(@degree_requirement),
                  notice: "Degree requirement was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @degree = @degree_requirement.degree
    @degree_requirement.destroy!

    respond_to do |format|
      format.html do
        redirect_to degree_path(@degree), notice: "Degree requirement was successfully destroyed."
      end
      format.json { head :no_content }
    end
  end

  private

  def set_degree_requirement
    @degree_requirement =
      DegreeRequirement.includes(course_requirements: :course).includes(:degree).find(params[:id])
  end

  def set_degree
    @degree = Degree.find(params[:degree_id])
  end

  def degree_requirement_params
    params.require(:degree_requirement).permit(:name, :credit_hour_amount, :degree_id)
  end
end
