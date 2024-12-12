class CreateCoursePrerequisites < ActiveRecord::Migration[7.1]
  def change
    create_table :course_prerequisites do |t|
      t.references :course, null: false, foreign_key: { to_table: :courses }
      t.references :prerequisite, null: false, foreign_key: { to_table: :courses }
      t.string :logic_type, null: false, default: "and"
      t.timestamps

      t.index %i[course_id prerequisite_id], unique: true
    end
  end
end
