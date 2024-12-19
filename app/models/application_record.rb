class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Overall model comments: there is one missing validation. Not allowing the request to be sent if all degree options are nil.
end
