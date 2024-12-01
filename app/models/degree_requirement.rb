# == Schema Information
#
# Table name: degree_requirements
#
#  id                 :bigint           not null, primary key
#  credit_hour_amount :integer
#  name               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  degree_id          :integer
#
class DegreeRequirement < ApplicationRecord
  belongs_to :degree, required: true, class_name: "Degree", foreign_key: "degree_id"
  has_many :course_requirements, dependent: :destroy
  has_many :courses, through: :course_requirements
  #has_many :transferable_courses, class_name: "TransferableCourse", foreign_key: "degree_requirement_id", dependent: :destroy
end
