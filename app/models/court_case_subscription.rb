# frozen_string_literal: true

class CourtCaseSubscription < ActiveRecord::Base
  belongs_to :user, optional: true

  has_many :checked_rights, class_name: 'Right', dependent: :destroy

  validates :case_number, presence: true

  def rights_hash
    Hash[Right::RIGHTS.values.map { |right| [right, false] }]
      .merge(Hash[checked_rights.map { |right| [right.name, true] }])
  end

  def checked_right?(flag)
    checked_rights.any? { |r| r.name == Right::RIGHTS[flag] }
  end
end
