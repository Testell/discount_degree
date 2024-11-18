class CreateTransferableCourses < ActiveRecord::Migration[7.1]
  def change
    create_table :transferable_courses do |t|
      t.integer :from_course_id
      t.integer :to_course_id
      t.integer :degree_requirement_id

      t.timestamps
    end
  end
end
