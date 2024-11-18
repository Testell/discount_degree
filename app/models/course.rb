class Course < ApplicationRecord
  belongs_to :school, required: true, class_name: "School", foreign_key: "school_id"
  belongs_to :degree_requirement, required: true, class_name: "DegreeRequirement", foreign_key: "degree_requirement_id"
  has_many  :start_transferable_courses, class_name: "Transferablecourse", foreign_key: "from_course_id", dependent: :destroy
  has_many  :end_transferable_courses, class_name: "Transferablecourse", foreign_key: "to_course_id", dependent: :destroy
end
