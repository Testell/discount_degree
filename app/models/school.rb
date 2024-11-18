class School < ApplicationRecord
has_many  :courses, class_name: "Course", foreign_key: "school_id", dependent: :destroy
has_many  :degrees, class_name: "Degree", foreign_key: "school_id", dependent: :destroy
end
