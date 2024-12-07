class CreateInitialSchema < ActiveRecord::Migration[7.1]
  def change
    create_table :schools do |t|
      t.string :name, null: false
      t.string :school_type, null: false
      t.integer :credit_hour_price
      t.integer :minimum_credits_from_school
      t.integer :max_credits_from_community_college
      t.integer :max_credits_from_university
      t.timestamps
    end

    create_table :terms do |t|
      t.string :name, null: false
      t.integer :credit_hour_minimum, null: false
      t.integer :credit_hour_maximum, null: false
      t.decimal :tuition_cost, precision: 10, scale: 2, null: false
      t.references :school, null: false, foreign_key: true
      t.timestamps
    end

    create_table :courses do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.integer :course_number, null: false
      t.string :department, null: false
      t.string :category
      t.decimal :credit_hours, precision: 5, scale: 4, null: false
      t.references :school, null: false, foreign_key: true
      t.timestamps
    end

    create_table :degrees do |t|
      t.string :name, null: false
      t.references :school, null: false, foreign_key: true
      t.timestamps
    end

    create_table :degree_requirements do |t|
      t.string :name, null: false
      t.integer :credit_hour_amount, null: false
      t.references :degree, null: false, foreign_key: true
      t.timestamps
    end

    create_table :course_requirements do |t|
      t.references :course, null: false, foreign_key: true
      t.references :degree_requirement, null: false, foreign_key: true
      t.boolean :is_mandatory, null: false, default: false
      t.timestamps

      t.index :is_mandatory
    end

    create_table :transferable_courses do |t|
      t.integer :from_course_id, null: false
      t.integer :to_course_id, null: false
      t.timestamps
    end

    create_table :plans do |t|
      t.references :degree, null: false, foreign_key: true
      t.references :starting_school, null: false, foreign_key: { to_table: :schools }
      t.references :ending_school, foreign_key: { to_table: :schools }
      t.references :intermediary_school, foreign_key: { to_table: :schools }
      t.integer :total_cost, null: false
      t.jsonb :path, null: false, default: []
      t.jsonb :term_assignments, null: false, default: []
      t.jsonb :transferable_courses, null: false, default: []
      t.timestamps
    end

    create_table :users do |t|
      t.string :email, null: false
      t.string :encrypted_password, null: false, default: ""
      t.string :username, null: false
      t.string :role, null: false
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.timestamps

      t.index :email, unique: true
      t.index :reset_password_token, unique: true
    end
  end
end
