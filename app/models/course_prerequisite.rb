# == Schema Information
#
# Table name: course_prerequisites
#
#  id              :bigint           not null, primary key
#  logic_type      :string           default("and"), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  course_id       :bigint           not null
#  prerequisite_id :bigint           not null
#
# Indexes
#
#  index_course_prerequisites_on_course_id                      (course_id)
#  index_course_prerequisites_on_course_id_and_prerequisite_id  (course_id,prerequisite_id) UNIQUE
#  index_course_prerequisites_on_prerequisite_id                (prerequisite_id)
#
# Foreign Keys
#
#  fk_rails_...  (course_id => courses.id)
#  fk_rails_...  (prerequisite_id => courses.id)
#
class CoursePrerequisite < ApplicationRecord
  belongs_to :course
  belongs_to :prerequisite, class_name: "Course", foreign_key: "prerequisite_id"

  validates :logic_type, presence: true, inclusion: { in: %w[and or] }
  validates :prerequisite_id, uniqueness: { scope: :course_id }
end
