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
    @other_courses = Course.where.not(id: @transferable_course.to_course_id)
  end

  def create
    @transferable_course = TransferableCourse.create_with_associations(transferable_course_params)
    @course = Course.find(transferable_course_params[:to_course_id])
    @other_courses = Course.for_transfer_form(@course.id)

    respond_to do |format|
      if @transferable_course.persisted?
        @saved_course = @transferable_course
        @transferable_course = TransferableCourse.initialize_for_course(@course.id)
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
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
    source_course_id = @transferable_course.to_course_id
    @transferable_course.destroy!

    respond_to do |format|
      format.html do
        redirect_to course_path(source_course_id),
                    notice: "Transfer relationship was successfully removed."
      end
      format.json { head :no_content }
    end
  end

  private

  def set_transferable_course
    @transferable_course = TransferableCourse.with_associated_courses.find(params[:id])
  end

  def transferable_course_params
    params.require(:transferable_course).permit(
      :from_course_id,
      :to_course_id,
      :degree_requirement_id
    )
  end
end
