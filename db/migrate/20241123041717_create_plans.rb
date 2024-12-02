class CreatePlans < ActiveRecord::Migration[7.1]
  def change
    create_table :plans do |t|
      t.references :degree, null: false, foreign_key: true
      t.references :starting_school, null: false, foreign_key: { to_table: :schools }
      t.references :ending_school, foreign_key: { to_table: :schools } 
      t.integer :total_cost, null: false
      t.text :path, null: false
      t.text :transferable_courses 
      t.timestamps
    end
  end
end
