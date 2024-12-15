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

  scope :with_associated_courses, -> { includes(from_course: :school, to_course: :school) }

  def formatted_relation
    "#{from_course.code} #{from_course.course_number} - #{from_course.name} (#{from_course.school.name}) ➔ " \
      "#{to_course.code} #{to_course.course_number} - #{to_course.name} (#{to_course.school.name})"
  end

  def from_course_details
    "#{from_course.code} #{from_course.course_number} - #{from_course.name} (#{from_course.school.name})"
  end

  def to_course_details
    "#{to_course.code} #{to_course.course_number} - #{to_course.name} (#{to_course.school.name})"
  end

  def self.create_with_associations(params)
    transferable_course = new(params)
    if transferable_course.save
      with_associated_courses.find(transferable_course.id)
    else
      transferable_course
    end
  end

  def self.initialize_for_course(course_id)
    new(to_course_id: course_id)
  end
end
