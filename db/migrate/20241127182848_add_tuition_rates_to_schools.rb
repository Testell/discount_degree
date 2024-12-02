class AddTuitionRatesToSchools < ActiveRecord::Migration[7.1]
  def change
    add_column :schools, :full_time_tuition, :integer
    add_column :schools, :part_time_tuition, :integer
    add_column :schools, :single_course_tuition, :integer
  end
end
