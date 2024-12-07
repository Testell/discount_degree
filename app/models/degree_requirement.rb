# == Schema Information
#
# Table name: degree_requirements
#
#  id                 :bigint           not null, primary key
#  credit_hour_amount :integer          not null
#  name               :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  degree_id          :bigint           not null
#
# Indexes
#
#  index_degree_requirements_on_degree_id  (degree_id)
#
# Foreign Keys
#
#  fk_rails_...  (degree_id => degrees.id)
#
class DegreeRequirement < ApplicationRecord
  belongs_to :degree, required: true, class_name: "Degree", foreign_key: "degree_id"
  has_many :course_requirements, dependent: :destroy
  has_many :courses, through: :course_requirements
end
