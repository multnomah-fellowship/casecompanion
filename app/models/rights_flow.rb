# This model is not persisted in the database!
class RightsFlow
  include ActiveModel::Model
  include ActiveModel::AttributeMethods

  FIELDS = %w[
    flag_a_assert_dda flag_a_let_me_choose

    flag_b_critical_stage
    flag_d_release_hearings
    flag_e_revocation_hearings

    flag_k_restitution

    flag_h_limited_distribution
    flag_i_no_media
    flag_j
    flag_f

    first_name last_name email phone_number
    case_number
  ]

  PAGES = %w[
    who_assert
    to_notification
    to_financial_assistance
    in_special_cases
    create_account
    confirm
  ]

  RIGHTS_MAPPING = {
    'flag_a_assert_dda' => Right::NAMES[0],
    'flag_b_critical_stage' => Right::NAMES[1],
    'flag_d_release_hearings' => Right::NAMES[3],
    'flag_e_revocation_hearings' => Right::NAMES[4],
    'flag_f' => Right::NAMES[5],
    'flag_h_limited_distribution' => Right::NAMES[7],
    'flag_i_no_media' => Right::NAMES[8],
    'flag_j' => Right::NAMES[9],
    'flag_k_restitution' => Right::NAMES[10],
  }

  attr_accessor :current_page, :court_case_subscription_id
  attr_accessor(*FIELDS)

  def persist!
    checked_rights = flow_attributes.map do |attr, value|
      Right.new(name: RIGHTS_MAPPING.fetch(attr)) if value.present? && value.to_i == 1
    end.compact

    # If there is a subscription already, update it
    if court_case_subscription_id
      subscription = CourtCaseSubscription.find(court_case_subscription_id)
      subscription.checked_rights = checked_rights
      subscription.save
    else
      # TODO: Add user first, last name, phone number in here too.
      CourtCaseSubscription.create(
        user: User.new(email: email),
        checked_rights: checked_rights,
        case_number: case_number
      )
    end
  end

  def skip_step?(step)
    return true if step == 'create_account' && court_case_subscription_id.present?
  end

  # ######################################################################
  # These are generic methods which could be extracted to a superclass:
  # ######################################################################

  def self.first_step
    PAGES[0]
  end

  def finished?
    next_step == PAGES[-1]
  end

  def self.from_cookie(cookie)
    new(**JSON.parse(Zlib::Inflate.inflate(Base64.decode64(cookie))).symbolize_keys)
  rescue
    nil
  end

  def next_step
    next_page = nil
    move_pages = 1
    loop do
      next_page = PAGES[PAGES.find_index(current_page) + move_pages]
      break unless skip_step?(next_page)
      move_pages += 1
    end
    next_page
  end

  def flow_attributes
    Hash[FIELDS.map { |f| [f, self.send(f)] }]
  end

  def to_cookie
    Base64.encode64(Zlib::Deflate.deflate(JSON.generate(flow_attributes)))
  end

  def ==(other)
    other.flow_attributes == flow_attributes
  end
end
