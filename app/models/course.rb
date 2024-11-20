# == Schema Information
#
# Table name: courses
#
#  id              :bigint           not null, primary key
#  code            :string
#  course_category :string
#  course_number   :integer
#  credit_hours    :string
#  name            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  school_id       :integer
#
class Course < ApplicationRecord
  belongs_to :school, required: true, class_name: "School", foreign_key: "school_id"

  has_many :course_requirements, dependent: :destroy
  has_many :degree_requirements, through: :course_requirements
  has_many :start_transferable_courses, class_name: "TransferableCourse", foreign_key: "from_course_id", dependent: :destroy
  has_many :end_transferable_courses, class_name: "TransferableCourse", foreign_key: "to_course_id", dependent: :destroy

  validates :course_number, presence: true, numericality: { only_integer: true }
  validates :course_category, presence: true
end
