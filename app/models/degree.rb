class Degree < ApplicationRecord
has_many  :degree_requirements, class_name: "DegreeRequirement", foreign_key: "degree_id", dependent: :destroy
belongs_to :school, required: true, class_name: "School", foreign_key: "school_id"
end
