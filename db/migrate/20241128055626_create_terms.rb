class CreateTerms < ActiveRecord::Migration[7.1]
  def change
    create_table :terms do |t|
      t.string :name
      t.integer :credit_hour_minimum
      t.integer :credit_hour_maximum
      t.decimal :tuition_cost, precision: 10, scale: 2
      t.references :school, null: false, foreign_key: true

      t.timestamps
    end
  end
end
