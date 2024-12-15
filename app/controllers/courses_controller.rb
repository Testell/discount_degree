class CoursesController < ApplicationController
  before_action { authorize(@course || Course) }
  before_action :set_course, only: %i[show edit update destroy]
  before_action :set_school, only: %i[create destroy]
  before_action :set_transferable_courses, only: [:show]

  def index
    @courses = Course.with_common_includes
  end

  def show
  end

  def new
    @course = Course.new
  end

  def create
    @course = Course.new_with_school(@school, course_params)

    respond_to do |format|
      if @course.save
        format.html do
          redirect_to school_path(@school, section: "courses"),
                      notice: "Course was successfully created."
        end
        format.json { render :show, status: :created, location: @course }
      else
        format.html do
          redirect_to school_path(@school, section: "courses"), status: :unprocessable_entity
        end
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @course.update(course_params)
        format.html { redirect_to course_url(@course), notice: "Course was successfully updated." }
        format.json { render :show, status: :ok, location: @course }
        format.js
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    school = @course.school
    @course.destroy!
    redirect_to school_path(school, section: "courses"),
                notice: "Course was successfully destroyed."
  end

  private

  def set_course
    @course =
      if action_name == "show"
        Course.find_for_show(params[:id])
      else
        Course.find_basic(params[:id])
      end
  end

  def set_school
    @school = (params[:school_id] ? School.find(params[:school_id]) : @course&.school)
  end

  def set_transferable_courses
    transfer_info = @course.transfer_details
    @transferable_courses = transfer_info[:transferable_courses]
    @transferable_course = transfer_info[:transferable_course]
    @other_courses = transfer_info[:other_courses]
  end

  def course_params
    params.require(:course).permit(
      :department,
      :category,
      :code,
      :course_number,
      :name,
      :credit_hours,
      :school_id
    )
  end
end
