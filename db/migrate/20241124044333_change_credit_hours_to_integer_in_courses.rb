class ChangeCreditHoursToIntegerInCourses < ActiveRecord::Migration[7.1]
  def change
    change_column :courses, :credit_hours, 'integer USING CAST(credit_hours AS integer)'
  end
end
