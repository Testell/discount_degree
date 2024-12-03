# == Schema Information
#
# Table name: optional_course_slots
#
#  id                    :bigint           not null, primary key
#  term_number           :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  degree_requirement_id :bigint           not null
#  plan_id               :bigint           not null
#
# Indexes
#
#  index_optional_course_slots_on_degree_requirement_id  (degree_requirement_id)
#  index_optional_course_slots_on_plan_id                (plan_id)
#
# Foreign Keys
#
#  fk_rails_...  (degree_requirement_id => degree_requirements.id)
#  fk_rails_...  (plan_id => plans.id)
#
class OptionalCourseSlot < ApplicationRecord
  belongs_to :plan
  belongs_to :degree_requirement
end
