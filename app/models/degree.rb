# == Schema Information
#
# Table name: degrees
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  school_id  :integer
#
class Degree < ApplicationRecord
has_many  :degree_requirements, class_name: "DegreeRequirement", foreign_key: "degree_id", dependent: :destroy
belongs_to :school, required: true, class_name: "School", foreign_key: "school_id"
end
