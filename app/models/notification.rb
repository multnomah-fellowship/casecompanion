class Notification < ApplicationRecord
  validates :first_name, presence: true
  validates :offender_sid, presence: true
  validates :phone_number, presence: true
end
