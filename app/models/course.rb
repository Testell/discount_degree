# == Schema Information
#
# Table name: courses
#
#  id            :bigint           not null, primary key
#  category      :string
#  code          :string
#  course_number :integer
#  credit_hours  :integer
#  department    :string
#  name          :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  school_id     :integer
#
class Course < ApplicationRecord
  belongs_to :school, required: true, class_name: "School", foreign_key: "school_id"

  has_many :course_requirements, dependent: :destroy
  has_many :degree_requirements, through: :course_requirements

  has_many :start_transferable_courses, class_name: "TransferableCourse", foreign_key: "from_course_id", dependent: :destroy
  has_many :end_transferable_courses, class_name: "TransferableCourse", foreign_key: "to_course_id", dependent: :destroy

  has_many :transferable_to_courses, through: :start_transferable_courses, source: :to_course
  has_many :transferable_from_courses, through: :end_transferable_courses, source: :from_course
end
