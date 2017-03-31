class Notification < ApplicationRecord
  # This special value will be used when we need to generate links for victims
  # whose offenders aren't in the system yet. We will still be able to track
  # click-throughs, and then add the SID later.
  UNKNOWN_SID = 'U'

  validates :first_name, presence: true
  validates :offender_sid, presence: true
  validates :phone_number, presence: true
end
