class TransferableCourse < ApplicationRecord
  belongs_to :degree_requirement, required: true, class_name: "DegreeRequirement", foreign_key: "degree_requirement_id"
  belongs_to :from_course, required: true, class_name: "Course", foreign_key: "from_course_id"
  belongs_to :to_course, required: true, class_name: "Course", foreign_key: "to_course_id"
end
