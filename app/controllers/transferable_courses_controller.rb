class TransferableCoursesController < ApplicationController
  before_action { authorize(@transferable_course || TransferableCourse) }
  before_action :set_transferable_course, only: %i[ show edit update destroy ]

  # GET /transferable_courses or /transferable_courses.json
  def index
    @transferable_courses = TransferableCourse.all
  end

  # GET /transferable_courses/1 or /transferable_courses/1.json
  def show
    @transferable_to_courses = @transferable_course.from_course.transferable_to_courses
    @transferable_from_courses = @transferable_course.from_course.transferable_from_courses
    @course = @transferable_course.to_course
  end

  # GET /transferable_courses/new
  def new
    @transferable_course = TransferableCourse.new
  end

  # GET /transferable_courses/1/edit
  def edit
  end

  # POST /transferable_courses or /transferable_courses.json
  def create
    @transferable_course = TransferableCourse.new(transferable_course_params)

    respond_to do |format|
      if @transferable_course.save
        format.html { redirect_to transferable_course_url(@transferable_course), notice: "Transferable course was successfully created." }
        format.json { render :show, status: :created, location: @transferable_course }
        format.js
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @transferable_course.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /transferable_courses/1 or /transferable_courses/1.json
  def update
    respond_to do |format|
      if @transferable_course.update(transferable_course_params)
        format.html { redirect_to transferable_course_url(@transferable_course), notice: "Transferable course was successfully updated." }
        format.json { render :show, status: :ok, location: @transferable_course }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @transferable_course.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transferable_courses/1 or /transferable_courses/1.json
  def destroy
    @transferable_course.destroy!

    respond_to do |format|
      format.html { redirect_to transferable_courses_url, notice: "Transferable course was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transferable_course
      @transferable_course = TransferableCourse.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def transferable_course_params
      params.require(:transferable_course).permit(:from_course_id, :to_course_id, :degree_requirement_id)
    end
end
