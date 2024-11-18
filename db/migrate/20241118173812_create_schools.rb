class CreateSchools < ActiveRecord::Migration[7.1]
  def change
    create_table :schools do |t|
      t.string :name
      t.string :school_type
      t.string :credit_hour_price
      t.string :minimum_credits_from_school
      t.string :max_credits_from_community_college
      t.string :max_credits_from_university

      t.timestamps
    end
  end
end
