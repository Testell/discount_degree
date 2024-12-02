class RemoveIsChoiceBasedFromDegreeRequirements < ActiveRecord::Migration[7.1]
  def change
    remove_column :degree_requirements, :is_choice_based, :boolean
  end
end
