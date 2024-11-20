class AddCourseNumberAndCourseCategoryToCourses < ActiveRecord::Migration[7.1]
  def change
    add_column :courses, :course_number, :integer
    add_column :courses, :course_category, :string
  end
end
