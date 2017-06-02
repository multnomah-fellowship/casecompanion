class CourtCaseSubscription < ActiveRecord::Base
  belongs_to :user

  validates :case_number, uniqueness: { scope: :user_id }
end
