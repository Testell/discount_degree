class SchoolsController < ApplicationController
  before_action { authorize(@school || School) }
  before_action :set_school, only: %i[show edit update destroy]

  def index
    @schools = School.includes(:terms).all
  end

  def show
    @school = School.includes(:terms, :degrees, :courses).find(params[:id])
    @degrees = @school.degrees
    @degree = Degree.new(school: @school)
    @courses = @school.courses
    @course = Course.new(school: @school)
    @terms = @school.terms
    @term = Term.new(school: @school)
  end

  def new
    @school = School.new
    @course = Course.new
  end

  def edit
  end

  def create
    @school = School.new(school_params)

    respond_to do |format|
      if @school.save
        format.html { redirect_to school_path(@school), notice: "School was successfully created." }
        format.json { render :show, status: :created, location: @school }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @school.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @school.update(school_params)
        format.html { redirect_to school_url(@school), notice: "School was successfully updated." }
        format.json { render :show, status: :ok, location: @school }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @school.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @school.destroy!

    respond_to do |format|
      format.html { redirect_to schools_url, notice: "School was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_school
    @school = School.includes(:terms, :degrees, :courses).find(params[:id])
  end

  def school_params
    params.require(:school).permit(
      :name,
      :school_type,
      :credit_hour_price,
      :full_time_tuition,
      :part_time_tuition,
      :single_course_tuition,
      :minimum_credits_from_school,
      :max_credits_from_community_college,
      :max_credits_from_university
    )
  end
end
