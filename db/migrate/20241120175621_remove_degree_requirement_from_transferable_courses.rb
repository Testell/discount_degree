class RemoveDegreeRequirementFromTransferableCourses < ActiveRecord::Migration[7.1]
  def change
    remove_column :transferable_courses, :degree_requirement_id, :integer
  end
end
