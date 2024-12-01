# == Schema Information
#
# Table name: terms
#
#  id                  :bigint           not null, primary key
#  credit_hour_maximum :integer
#  credit_hour_minimum :integer
#  name                :string
#  tuition_cost        :decimal(10, 2)
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
end
