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

  scope :basic_load, -> { all }

  scope :with_display_includes, -> { includes(:school) }

  scope :with_common_includes, -> { includes(:school, :degree_requirements) }

  scope :with_show_includes, -> { includes(:school) }

  scope :except_course, ->(course) { where.not(id: course.id) }

  def self.find_for_show(id)
    with_show_includes.find(id)
  end

  def self.find_basic(id)
    basic_load.find(id)
  end

  def self.new_with_school(school, params = {})
    school.courses.build(params)
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[name code course_number]
  end

  def self.ransackable_associations(auth_object = nil)
    ["school"]
  end

  def transfer_details
    {
      transferable_courses: transferable_course_relationships,
      transferable_course: TransferableCourse.new(to_course: self),
      other_courses: available_for_transfer
    }
  end

  def transferable_course_relationships
    TransferableCourse.includes(from_course: :school, to_course: :school).where(
      "from_course_id = :id OR to_course_id = :id",
      id: id
    )
  end

  def available_for_transfer
    self.class.with_display_includes.except_course(self)
  end

  def name_with_school
    "#{code} - #{course_number} #{name} (#{school.name})"
  end

  ransacker :course_number_search do
    Arel.sql("CAST(course_number AS TEXT)")
  end

  def self.for_transfer_form(excluding_course_id)
    where.not(id: excluding_course_id).with_display_includes
  end
end
