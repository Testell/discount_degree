# == Schema Information
#
# Table name: course_requirements
#
#  id                    :bigint           not null, primary key
#  is_mandatory          :boolean          default(FALSE), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  course_id             :bigint           not null
#  degree_requirement_id :bigint           not null
#
# Indexes
#
#  index_course_requirements_on_course_id              (course_id)
#  index_course_requirements_on_degree_requirement_id  (degree_requirement_id)
#  index_course_requirements_on_is_mandatory           (is_mandatory)
#
# Foreign Keys
#
#  fk_rails_...  (course_id => courses.id)
#  fk_rails_...  (degree_requirement_id => degree_requirements.id)
#
class CourseRequirement < ApplicationRecord
  belongs_to :course, required: true, class_name: "Course", foreign_key: "course_id"
  belongs_to :degree_requirement,
             required: true,
             class_name: "DegreeRequirement",
             foreign_key: "degree_requirement_id"
end
