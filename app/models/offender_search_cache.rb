class OffenderSearchCache < ActiveRecord::Base
  serialize :data, JSON
end
