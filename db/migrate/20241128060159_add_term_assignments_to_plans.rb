class AddTermAssignmentsToPlans < ActiveRecord::Migration[7.1]
  def change
    add_column :plans, :term_assignments, :jsonb, default: {}
  end
end
