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
      if params[:q].present?
        base_query.joins(:courses).merge(Course.ransack(params[:q]).result).distinct
      else
        base_query.includes(:courses)
      end
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
      @courses = params[:q].present? ? @q_courses.result : @school.courses
      @course = Course.new(school: @school)
    end
  end
end
