# == Schema Information
#
# Table name: schools
#
#  id                                 :bigint           not null, primary key
#  credit_hour_price                  :integer
#  max_credits_from_community_college :integer
#  max_credits_from_university        :integer
#  minimum_credits_from_school        :integer
#  name                               :string           not null
#  school_type                        :string           not null
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#
class School < ApplicationRecord
  has_many :courses, class_name: "Course", foreign_key: "school_id", dependent: :destroy
  has_many :degrees, class_name: "Degree", foreign_key: "school_id", dependent: :destroy
  has_many :terms, dependent: :destroy

  scope :community_colleges, -> { where(school_type: "community_college") }
  scope :universities, -> { where(school_type: "university") }

  scope :offering_degree, ->(degree_id) { joins(:degrees).where(degrees: { id: degree_id }) }
end
