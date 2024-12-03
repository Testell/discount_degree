class CreateUserPlans < ActiveRecord::Migration[7.1]
  def change
    create_table :user_plans do |t|
      t.references :user, null: false, foreign_key: true
      t.references :plan, null: false, foreign_key: true
      t.references :optional_course_slot, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :user_plans, [:user_id, :optional_course_slot_id], unique: true
  end
end
