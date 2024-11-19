# == Schema Information
#
# Table name: transferable_courses
#
#  id                    :bigint           not null, primary key
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  degree_requirement_id :integer
#  from_course_id        :integer
#  to_course_id          :integer
#
class TransferableCourse < ApplicationRecord
  belongs_to :degree_requirement, required: true, class_name: "DegreeRequirement", foreign_key: "degree_requirement_id"
  belongs_to :from_course, required: true, class_name: "Course", foreign_key: "from_course_id"
  belongs_to :to_course, required: true, class_name: "Course", foreign_key: "to_course_id"
end