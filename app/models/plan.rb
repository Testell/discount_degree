# == Schema Information
#
# Table name: plans
#
#  id                     :bigint           not null, primary key
#  path                   :jsonb            not null
#  plan_type              :string
#  term_assignments       :jsonb            not null
#  total_cost             :integer          not null
#  transferable_courses   :jsonb            not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  degree_id              :bigint           not null
#  ending_school_id       :bigint
#  intermediary_school_id :bigint
#  starting_school_id     :bigint           not null
#
# Indexes
#
#  index_plans_on_degree_id               (degree_id)
#  index_plans_on_ending_school_id        (ending_school_id)
#  index_plans_on_intermediary_school_id  (intermediary_school_id)
#  index_plans_on_plan_type               (plan_type)
#  index_plans_on_starting_school_id      (starting_school_id)
#
# Foreign Keys
#
#  fk_rails_...  (degree_id => degrees.id)
#  fk_rails_...  (ending_school_id => schools.id)
#  fk_rails_...  (intermediary_school_id => schools.id)
#  fk_rails_...  (starting_school_id => schools.id)
#
class Plan < ApplicationRecord
  belongs_to :degree
  belongs_to :starting_school, class_name: "School", foreign_key: "starting_school_id"
  belongs_to :ending_school, class_name: "School", foreign_key: "ending_school_id", optional: true

  has_many :saved_plans, dependent: :destroy
  has_many :users, through: :saved_plans

  validates :total_cost, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def path
    self[:path] || []
  end

  def term_assignments
    self[:term_assignments] || []
  end

  def transferable_courses
    return [] if self[:transferable_courses].nil?
    Array(self[:transferable_courses])
  end

  def total_credit_hours
    term_assignments.sum { |term| term["credit_hours"].to_f }
  end

  private

  def ensure_json_arrays
    self.path = [] if path.nil?
    self.term_assignments = [] if term_assignments.nil?
    self.transferable_courses = [] if transferable_courses.nil?
  end
end
