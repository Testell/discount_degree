# == Schema Information
#
# Table name: plans
#
#  id                   :bigint           not null, primary key
#  path                 :text             not null
#  total_cost           :integer          not null
#  transferable_courses :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  degree_id            :bigint           not null
#  ending_school_id     :bigint
#  starting_school_id   :bigint           not null
#
# Indexes
#
#  index_plans_on_degree_id           (degree_id)
#  index_plans_on_ending_school_id    (ending_school_id)
#  index_plans_on_starting_school_id  (starting_school_id)
#
# Foreign Keys
#
#  fk_rails_...  (degree_id => degrees.id)
#  fk_rails_...  (ending_school_id => schools.id)
#  fk_rails_...  (starting_school_id => schools.id)
#
class Plan < ApplicationRecord
  belongs_to :degree
  belongs_to :starting_school, class_name: "School", foreign_key: "starting_school_id"
  belongs_to :ending_school, class_name: "School", foreign_key: "ending_school_id", optional: true

  serialize :transferable_courses, type: Array
  
  validates :total_cost, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :path, presence: true
end
