class SchoolsController < ApplicationController
  include SchoolSectionLoader
  before_action { authorize(@school || School) }
  before_action :set_school, only: %i[show edit update destroy scrape_courses]

  def index
    @schools = School.includes(:terms).all
  end

  def show
    load_school_with_section

    respond_to do |format|
      format.html
      format.turbo_stream do
        if params[:q]
          render turbo_stream:
                   turbo_stream.update(
                     "courses-list",
                     partial: "schools/courses_list",
                     locals: {
                       courses: @courses,
                       school: @school
                     }
                   )
        else
          render turbo_stream: [
                   turbo_stream.update(
                     "section_content",
                     partial: "schools/section",
                     locals: {
                       section: params[:section],
                       courses: @courses,
                       degrees: @degrees,
                       terms: @terms,
                       school: @school
                     }
                   ),
                   turbo_stream.update(
                     "navigation",
                     partial: "schools/navigation",
                     locals: {
                       school: @school,
                       current_section: params[:section]
                     }
                   )
                 ]
        end
      end
    end
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

  def scrape_courses
    result = WebscraperServices::DepaulCourseScraperService.call(@school)

    respond_to do |format|
      format.turbo_stream do
        @courses = @school.courses.page(params[:page]).per(10)
        @course = Course.new(school: @school)

        render turbo_stream: [
                 turbo_stream.replace(
                   "section_content",
                   partial: "schools/section",
                   locals: {
                     section: "courses",
                     courses: @courses,
                     school: @school,
                     degrees: @degrees,
                     terms: @terms
                   }
                 ),
                 turbo_stream.replace(
                   "alerts",
                   partial: "layouts/shared/alerts",
                   locals: {
                     notice:
                       (
                         if result[:errors].empty?
                           "Successfully processed #{result[:processed]} courses"
                         else
                           "Encountered errors while processing courses: #{result[:errors].join(", ")}"
                         end
                       ),
                     alert: nil
                   }
                 )
               ]
      end
    end
  end

  private

  def set_school
    @school = School.find(params[:id])
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
