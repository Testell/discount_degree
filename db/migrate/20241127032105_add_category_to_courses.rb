class AddCategoryToCourses < ActiveRecord::Migration[7.1]
  def change
    rename_column :courses, :course_category, :department
    add_column :courses, :category, :string
  end
end
