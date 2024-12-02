class ChangeCreditHoursToDecimalInCourses < ActiveRecord::Migration[7.1]
  def change
    change_column :courses, :credit_hours, :decimal, precision: 5, scale: 4
  end
end
