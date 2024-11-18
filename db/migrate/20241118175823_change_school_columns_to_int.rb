class ChangeSchoolColumnsToInt < ActiveRecord::Migration[7.1]
  def change
    change_column :schools, :credit_hour_price, :integer, using: 'credit_hour_price::integer'
    change_column :schools, :minimum_credits_from_school, :integer, using: 'minimum_credits_from_school::integer'
    change_column :schools, :max_credits_from_community_college, :integer, using: 'max_credits_from_community_college::integer'
    change_column :schools, :max_credits_from_university, :integer, using: 'max_credits_from_university::integer'

    change_column :degree_requirements, :credit_hour_amount, :integer, using: 'credit_hour_amount::integer'
  end
end
