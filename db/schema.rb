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

ActiveRecord::Schema[7.1].define(version: 2024_12_03_022421) do
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
    t.decimal "credit_hours", precision: 5, scale: 4
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

  create_table "optional_course_slots", force: :cascade do |t|
    t.bigint "plan_id", null: false
    t.bigint "degree_requirement_id", null: false
    t.integer "term_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["degree_requirement_id"], name: "index_optional_course_slots_on_degree_requirement_id"
    t.index ["plan_id"], name: "index_optional_course_slots_on_plan_id"
  end

  create_table "plans", force: :cascade do |t|
    t.bigint "degree_id", null: false
    t.bigint "starting_school_id", null: false
    t.bigint "ending_school_id"
    t.integer "total_cost", null: false
    t.jsonb "path", null: false
    t.text "transferable_courses"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "term_assignments", default: {}
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
  end

  create_table "terms", force: :cascade do |t|
    t.string "name"
    t.integer "credit_hour_minimum"
    t.integer "credit_hour_maximum"
    t.decimal "tuition_cost", precision: 10, scale: 2
    t.bigint "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_terms_on_school_id"
  end

  create_table "transferable_courses", force: :cascade do |t|
    t.integer "from_course_id"
    t.integer "to_course_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_plans", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "plan_id", null: false
    t.bigint "optional_course_slot_id", null: false
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_user_plans_on_course_id"
    t.index ["optional_course_slot_id"], name: "index_user_plans_on_optional_course_slot_id"
    t.index ["plan_id"], name: "index_user_plans_on_plan_id"
    t.index ["user_id", "optional_course_slot_id"], name: "index_user_plans_on_user_id_and_optional_course_slot_id", unique: true
    t.index ["user_id"], name: "index_user_plans_on_user_id"
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
  add_foreign_key "optional_course_slots", "degree_requirements"
  add_foreign_key "optional_course_slots", "plans"
  add_foreign_key "plans", "degrees"
  add_foreign_key "plans", "schools", column: "ending_school_id"
  add_foreign_key "plans", "schools", column: "starting_school_id"
  add_foreign_key "terms", "schools"
  add_foreign_key "user_plans", "courses"
  add_foreign_key "user_plans", "optional_course_slots"
  add_foreign_key "user_plans", "plans"
  add_foreign_key "user_plans", "users"
end
