# == Schema Information
#
# Table name: saved_plans
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  plan_id    :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_saved_plans_on_plan_id  (plan_id)
#  index_saved_plans_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (plan_id => plans.id)
#
class SavedPlan < ApplicationRecord
  belongs_to :user
  belongs_to :plan

  validates :user_id, uniqueness: { scope: :plan_id, message: "has already saved this plan." }
end
