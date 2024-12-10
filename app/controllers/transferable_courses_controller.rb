class TransferableCoursesController < ApplicationController
  before_action { authorize(@transferable_course || TransferableCourse) }
  before_action :set_transferable_course, only: %i[show edit update destroy]

  def index
    @transferable_courses = TransferableCourse.all
  end

  def show
    @transferable_to_courses = @transferable_course.from_course.transferable_to_courses
    @transferable_from_courses = @transferable_course.from_course.transferable_from_courses
    @course = @transferable_course.to_course
  end

  def new
    @transferable_course = TransferableCourse.new
  end

  def edit
  end

  def create
    @transferable_course = TransferableCourse.new(transferable_course_params)

    respond_to do |format|
      if @transferable_course.save
        format.html do
          redirect_to transferable_course_url(@transferable_course),
                      notice: "Transferable course was successfully created."
        end
        format.json { render :show, status: :created, location: @transferable_course }
        format.js
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @transferable_course.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @transferable_course.update(transferable_course_params)
        format.html do
          redirect_to transferable_course_url(@transferable_course),
                      notice: "Transferable course was successfully updated."
        end
        format.json { render :show, status: :ok, location: @transferable_course }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @transferable_course.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @transferable_course.destroy!

    respond_to do |format|
      format.html do
        redirect_to transferable_courses_url,
                    notice: "Transferable course was successfully destroyed."
      end
      format.json { head :no_content }
    end
  end

  private

  def set_transferable_course
    @transferable_course = TransferableCourse.find(params[:id])
  end

  def transferable_course_params
    params.require(:transferable_course).permit(
      :from_course_id,
      :to_course_id,
      :degree_requirement_id
    )
  end
end
