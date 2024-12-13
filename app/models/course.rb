# == Schema Information
#
# Table name: courses
#
#  id            :bigint           not null, primary key
#  category      :string
#  code          :string           not null
#  course_number :integer          not null
#  credit_hours  :decimal(5, 4)    not null
#  department    :string           not null
#  description   :text
#  name          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  school_id     :bigint           not null
#
# Indexes
#
#  index_courses_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id)
#
class Course < ApplicationRecord
  belongs_to :school, required: true, class_name: "School", foreign_key: "school_id"
  belongs_to :term, optional: true

  has_many :course_requirements, dependent: :destroy
  has_many :degree_requirements, through: :course_requirements

  has_many :course_prerequisites, dependent: :destroy
  has_many :prerequisites, through: :course_prerequisites, source: :prerequisite

  has_many :prerequisite_for,
           class_name: "CoursePrerequisite",
           foreign_key: "prerequisite_id",
           dependent: :destroy

  has_many :start_transferable_courses,
           class_name: "TransferableCourse",
           foreign_key: "from_course_id",
           dependent: :destroy
  has_many :end_transferable_courses,
           class_name: "TransferableCourse",
           foreign_key: "to_course_id",
           dependent: :destroy

  has_many :transferable_to_courses, through: :start_transferable_courses, source: :to_course
  has_many :transferable_from_courses, through: :end_transferable_courses, source: :from_course

  def name_with_school
    "#{code} - #{course_number} #{name} (#{school.name})"
  end
end
