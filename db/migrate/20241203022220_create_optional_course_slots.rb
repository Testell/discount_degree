class CreateOptionalCourseSlots < ActiveRecord::Migration[7.1]
  def change
    create_table :optional_course_slots do |t|
      t.references :plan, null: false, foreign_key: true
      t.references :degree_requirement, null: false, foreign_key: true
      t.integer :term_number

      t.timestamps
    end
  end
end
