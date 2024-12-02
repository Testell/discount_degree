class ChangePathToJsonbInPlans < ActiveRecord::Migration[7.1]
  def change
    change_column :plans, :path, :jsonb, using: 'path::jsonb'
  end
end
