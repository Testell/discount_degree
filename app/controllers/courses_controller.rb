class CoursesController < ApplicationController
  before_action { authorize(@course || Course) }
  before_action :set_course, only: %i[show edit update destroy]
  before_action :set_school, only: [:create]

  def index
    @courses = Course.all
  end

  def show
    @course = Course.find(params[:id])
    @transferable_courses = @course.end_transferable_courses || []
    @transferable_course = TransferableCourse.new(to_course: @course)
    @other_courses = Course.where.not(school_id: @course.school_id)
  end

  def new
    @course = Course.new
  end

  def create
    @course = @school.courses.build(course_params)

    respond_to do |format|
      if @course.save
        format.html { redirect_to @course, notice: "Course was successfully created." }
        format.json { render :show, status: :created, location: @course }
        format.js
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @course.errors, status: :unprocessable_entity }
        format.js
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
    @course.destroy!

    respond_to do |format|
      format.html { redirect_to courses_url, notice: "Course was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_course
    @course = Course.find(params[:id])
  end

  def set_school
    @school = School.find(params[:school_id])
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
