class CourtCaseSubscription < ActiveRecord::Base
  belongs_to :user

  has_many :checked_rights, class_name: 'Right', dependent: :destroy

  validates :case_number, uniqueness: { scope: :user_id }

  def rights_hash
    Hash[Right::NAMES.map { |right| [right, false] }]
      .merge(Hash[checked_rights.map { |right| [right.name, true] }])
  end
end
