class CreateDegrees < ActiveRecord::Migration[7.1]
  def change
    create_table :degrees do |t|
      t.string :name
      t.integer :school_id

      t.timestamps
    end
  end
end
