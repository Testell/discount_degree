# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_11_27_182848) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "course_requirements", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.bigint "degree_requirement_id", null: false
    t.boolean "is_mandatory", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_course_requirements_on_course_id"
    t.index ["degree_requirement_id"], name: "index_course_requirements_on_degree_requirement_id"
    t.index ["is_mandatory"], name: "index_course_requirements_on_is_mandatory"
  end

  create_table "courses", force: :cascade do |t|
    t.integer "credit_hours"
    t.integer "school_id"
    t.string "name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "course_number"
    t.string "department"
    t.string "category"
  end

  create_table "degree_requirements", force: :cascade do |t|
    t.string "name"
    t.integer "credit_hour_amount"
    t.integer "degree_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "degrees", force: :cascade do |t|
    t.string "name"
    t.integer "school_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plans", force: :cascade do |t|
    t.bigint "degree_id", null: false
    t.bigint "starting_school_id", null: false
    t.bigint "ending_school_id"
    t.integer "total_cost", null: false
    t.text "path", null: false
    t.text "transferable_courses"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["degree_id"], name: "index_plans_on_degree_id"
    t.index ["ending_school_id"], name: "index_plans_on_ending_school_id"
    t.index ["starting_school_id"], name: "index_plans_on_starting_school_id"
  end

  create_table "schools", force: :cascade do |t|
    t.string "name"
    t.string "school_type"
    t.integer "credit_hour_price"
    t.integer "minimum_credits_from_school"
    t.integer "max_credits_from_community_college"
    t.integer "max_credits_from_university"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "full_time_tuition"
    t.integer "part_time_tuition"
    t.integer "single_course_tuition"
  end

  create_table "transferable_courses", force: :cascade do |t|
    t.integer "from_course_id"
    t.integer "to_course_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "username"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "course_requirements", "courses"
  add_foreign_key "course_requirements", "degree_requirements"
  add_foreign_key "plans", "degrees"
  add_foreign_key "plans", "schools", column: "ending_school_id"
  add_foreign_key "plans", "schools", column: "starting_school_id"
end
