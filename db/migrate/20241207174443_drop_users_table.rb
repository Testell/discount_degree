class DropUsersTable < ActiveRecord::Migration[7.1]
  def up
    drop_table :users
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
