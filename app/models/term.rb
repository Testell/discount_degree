# == Schema Information
#
# Table name: terms
#
#  id                  :bigint           not null, primary key
#  credit_hour_maximum :integer          not null
#  credit_hour_minimum :integer          not null
#  name                :string           not null
#  tuition_cost        :decimal(10, 2)   not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  school_id           :bigint           not null
#
# Indexes
#
#  index_terms_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id)
#
class Term < ApplicationRecord
  belongs_to :school

  validates :credit_hour_minimum, :credit_hour_maximum, :tuition_cost, presence: true, numericality: true

  has_many :courses
end
