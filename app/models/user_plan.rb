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

  validates :user_id, uniqueness: { scope: :optional_course_slot_id, message: "has already selected a course for this slot" }
  validate :course_belongs_to_slot

  after_create :update_plan_credit_hours
  after_destroy :recalculate_plan_credit_hours

  private

  def course_belongs_to_slot
    unless optional_course_slot.degree_requirement.courses.include?(course)
      errors.add(:course_id, "is not valid for the selected optional course slot")
    end
  end

  def update_plan_credit_hours
    plan.update(total_credit_hours: plan.total_credit_hours + course.credit_hours)
    plan.update(total_cost: plan.total_cost + course.cost)
  end

  def recalculate_plan_credit_hours
    plan.update(total_credit_hours: plan.total_credit_hours - course.credit_hours)
    plan.update(total_cost: plan.total_cost - course.cost)
  end
end
