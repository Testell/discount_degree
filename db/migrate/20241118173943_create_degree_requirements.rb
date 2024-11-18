class CreateDegreeRequirements < ActiveRecord::Migration[7.1]
  def change
    create_table :degree_requirements do |t|
      t.string :name
      t.string :credit_hour_amount
      t.integer :degree_id

      t.timestamps
    end
  end
end
