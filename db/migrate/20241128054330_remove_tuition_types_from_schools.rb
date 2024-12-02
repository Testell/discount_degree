class RemoveTuitionTypesFromSchools < ActiveRecord::Migration[7.1]
  def change
    remove_column :schools, :full_time_tuition, :integer
    remove_column :schools, :part_time_tuition, :integer
    remove_column :schools, :single_course_tuition, :integer
  end
end
