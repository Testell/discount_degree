# == Schema Information
#
# Table name: transferable_courses
#
#  id             :bigint           not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  from_course_id :integer          not null
#  to_course_id   :integer          not null
#
class TransferableCourse < ApplicationRecord
  belongs_to :from_course, required: true, class_name: "Course", foreign_key: "from_course_id"
  belongs_to :to_course, required: true, class_name: "Course", foreign_key: "to_course_id"

  validates :from_course, presence: true
  validates :to_course, presence: true
end
