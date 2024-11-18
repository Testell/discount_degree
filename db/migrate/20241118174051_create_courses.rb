class CreateCourses < ActiveRecord::Migration[7.1]
  def change
    create_table :courses do |t|
      t.string :credit_hours
      t.integer :school_id
      t.string :name
      t.string :code
      t.integer :degree_requirement_id

      t.timestamps
    end
  end
end
