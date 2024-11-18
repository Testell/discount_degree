class CourseRequirement < ApplicationRecord
  belongs_to :course, required: true, class_name: "Course", foreign_key: "course_id"
  belongs_to :degree_requirement, required: true, class_name: "DegreeRequirement", foreign_key: "degree_requirement_id"
end
