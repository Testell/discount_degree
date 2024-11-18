# == Schema Information
#
# Table name: schools
#
#  id                                 :bigint           not null, primary key
#  credit_hour_price                  :integer
#  max_credits_from_community_college :integer
#  max_credits_from_university        :integer
#  minimum_credits_from_school        :integer
#  name                               :string
#  school_type                        :string
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#
class School < ApplicationRecord
has_many  :courses, class_name: "Course", foreign_key: "school_id", dependent: :destroy
has_many  :degrees, class_name: "Degree", foreign_key: "school_id", dependent: :destroy
end
