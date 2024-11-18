class UpdateCoursesAndDegreeRequirementsAndAddCourseRequirements < ActiveRecord::Migration[7.1]
  def change
    change_table :courses do |t|
      t.remove :degree_requirement_id 
    end

    change_table :degree_requirements do |t|
      t.boolean :is_choice_based, default: false, null: false 
    end

    create_table :course_requirements do |t|
      t.references :course, null: false, foreign_key: { to_table: :courses } 
      t.references :degree_requirement, null: false, foreign_key: { to_table: :degree_requirements } 
      t.boolean :is_mandatory, default: false, null: false 

      t.timestamps
    end
  end
end
