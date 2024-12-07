# == Schema Information
#
# Table name: degrees
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  school_id  :bigint           not null
#
# Indexes
#
#  index_degrees_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id)
#
class Degree < ApplicationRecord
has_many  :degree_requirements, class_name: "DegreeRequirement", foreign_key: "degree_id", dependent: :destroy
belongs_to :school, required: true, class_name: "School", foreign_key: "school_id"
has_many :plans, dependent: :destroy
end
