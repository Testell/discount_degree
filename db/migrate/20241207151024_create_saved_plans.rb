class CreateSavedPlans < ActiveRecord::Migration[7.1]
  def change
    create_table :saved_plans do |t|
      t.references :user, foreign_key: true
      t.references :plan, foreign_key: true

      t.timestamps
    end
  end
end
