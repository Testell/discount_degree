module SchoolSectionLoader
  extend ActiveSupport::Concern

  private

  def load_school_with_section
    @school = find_school_with_includes
    load_section_resources
  end

  def find_school_with_includes
    base_query = School.where(id: params[:id])

    case params[:section]
    when "degrees"
      base_query.includes(:degrees)
    when "terms"
      base_query.includes(:terms)
    else
      base_query
    end.first!
  end

  def load_section_resources
    case params[:section]
    when "degrees"
      @degrees = @school.degrees
      @degree = Degree.new(school: @school)
    when "terms"
      @terms = @school.terms
      @term = Term.new(school: @school)
    else
      @q_courses = @school.courses.ransack(params[:q])
      @courses =
        if params[:q].present?
          @q_courses.result.distinct.page(params[:page]).per(10)
        else
          @school.courses.page(params[:page]).per(10)
        end
      @course = Course.new(school: @school)
    end
  end
end
