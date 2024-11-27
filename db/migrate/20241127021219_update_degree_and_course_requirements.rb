class UpdateDegreeAndCourseRequirements < ActiveRecord::Migration[7.1]
  def change
    change_column_default :course_requirements, :is_mandatory, from: nil, to: false
    change_column_null :course_requirements, :is_mandatory, false

    add_index :course_requirements, :is_mandatory
  end
end
