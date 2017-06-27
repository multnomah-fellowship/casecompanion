class BetaSignup < ApplicationRecord
  belongs_to :utm_attribution
  accepts_nested_attributes_for :utm_attribution
end
