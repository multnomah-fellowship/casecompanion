# frozen_string_literal: true

class CourtCaseSubscription < ActiveRecord::Base
  belongs_to :user, optional: true

  has_many :checked_rights, class_name: 'Right', dependent: :destroy

  validates :case_number, presence: true
  validate :ensure_contact_information

  def ensure_contact_information
    user.present? || email.present? || phone_number.present?
  end

  def rights_hash
    Hash[Right::NAMES.map { |right| [right, false] }]
      .merge(Hash[checked_rights.map { |right| [right.name, true] }])
  end
end
