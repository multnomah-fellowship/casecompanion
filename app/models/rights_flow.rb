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

  attr_accessor :current_page, :court_case_subscription_id
  attr_accessor(*FIELDS)

  def persist!
    # TODO: Implement this.
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
