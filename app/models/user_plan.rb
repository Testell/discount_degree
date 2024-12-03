# == Schema Information
#
# Table name: user_plans
#
#  id                      :bigint           not null, primary key
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  course_id               :bigint           not null
#  optional_course_slot_id :bigint           not null
#  plan_id                 :bigint           not null
#  user_id                 :bigint           not null
#
# Indexes
#
#  index_user_plans_on_course_id                            (course_id)
#  index_user_plans_on_optional_course_slot_id              (optional_course_slot_id)
#  index_user_plans_on_plan_id                              (plan_id)
#  index_user_plans_on_user_id                              (user_id)
#  index_user_plans_on_user_id_and_optional_course_slot_id  (user_id,optional_course_slot_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (course_id => courses.id)
#  fk_rails_...  (optional_course_slot_id => optional_course_slots.id)
#  fk_rails_...  (plan_id => plans.id)
#  fk_rails_...  (user_id => users.id)
#
class UserPlan < ApplicationRecord
  belongs_to :user
  belongs_to :plan
  belongs_to :optional_course_slot
  belongs_to :course
end
