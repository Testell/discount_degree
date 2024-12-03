class OptionalCourseSlot < ApplicationRecord
  belongs_to :plan
  belongs_to :degree_requirement
end
