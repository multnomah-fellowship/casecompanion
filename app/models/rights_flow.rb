# frozen_string_literal: true

# This model is not persisted in the database!
# Rather, it accumulates state on each page of the flow, and at the end of the
# flow, the #persist! method is called, at which time it creates related
# objects.
class RightsFlow
  include ActiveModel::Model
  include ActiveModel::AttributeMethods

  # The attributes of this model which will be set by <form> elements. These
  # fields will all be persisted in the flow cookie.
  FIELDS = %w[
    flag_a
    flag_b
    flag_c
    flag_d
    flag_e
    flag_f
    flag_g
    flag_h
    flag_i
    flag_j
    flag_k
    flag_m
    first_name
    last_name
    email
    phone_number
    case_number
    court_case_subscription_id
  ].freeze

  # The ordered steps of the flow, all of which will be the `id` in the route
  # /rights/:id
  PAGES = %w[
    who_assert
    to_notification
    to_financial_assistance
    in_special_cases
    create_account
    confirm
  ].freeze

  attr_accessor :current_page
  attr_accessor(*FIELDS)
  attr_reader :errors

  def initialize(*)
    @errors = ActiveModel::Errors.new(self)
    super
  end

  def validate!
    case current_page
    when 'create_account'
      unless court_case_subscription_id.present?
        errors.add(:first_name, :blank) unless first_name.present?
        errors.add(:last_name, :blank) unless last_name.present?
        errors.add(:email, :blank) unless email.present?
        errors.add(:phone_number, :blank) unless phone_number.present?
        errors.add(:case_number, :blank) unless case_number.present?
      end
    end
  end

  def persist!
    # Computed fields are still persisted in the session, but are not visible
    # to the user. They are not the rights checkboxes.
    computed_fields = %w[court_case_subscription_id]

    checked_rights =
      flow_attributes
        .without(*computed_fields)
        .find_all { |_attr, value| value.present? && value.to_i == 1 }
        .map { |attr, _value| Right.new(name: Right::RIGHTS.fetch(attr.to_sym)) }
        .compact

    # If there is a subscription already, update it
    subscription = if court_case_subscription_id
                     CourtCaseSubscription
                       .find(court_case_subscription_id)
                   else
                     CourtCaseSubscription.new
                   end

    previous_rights_hash = subscription.rights_hash

    # Update the subscription's properties.
    # If only the `checked_rights` are changed, then we need to manually
    # update the updated_at field of the CourtCaseSubscription.
    #
    # (Using `belongs_to ..., touch: true` results in the timestamp being
    # updated twice.)
    subscription.assign_attributes(
      checked_rights: checked_rights,
      case_number: case_number,
      first_name: first_name,
      last_name: last_name,
      email: email,
      phone_number: phone_number,
    )

    if subscription.persisted? &&
        subscription.rights_hash != previous_rights_hash
      subscription.touch
    end

    subscription.save

    self.court_case_subscription_id = subscription.id
  end

  def skip_step?(step)
    return true if step == 'create_account' && court_case_subscription_id.present?
  end

  def just_created?
    return false unless court_case_subscription_id
    subscription = CourtCaseSubscription.find(court_case_subscription_id)
    return false unless subscription

    subscription.created_at == subscription.updated_at
  end

  # ######################################################################
  # These are generic methods which could be extracted to a superclass:
  # ######################################################################

  def self.first_step
    PAGES[0]
  end

  def self.from_cookie(cookie)
    new(**JSON.parse(Zlib::Inflate.inflate(Base64.decode64(cookie))).symbolize_keys)
  rescue
    nil
  end

  def finished?
    next_step == PAGES[-1]
  end

  def previous_step
    previous_page = nil
    move_pages = 1
    loop do
      i = PAGES.find_index(current_page) - move_pages
      break if i.negative?
      previous_page = PAGES[i]
      break unless skip_step?(previous_page)
      move_pages += 1
    end
    previous_page
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

  def current_progress_percent
    seen_pages = PAGES.find_index(current_page) + 1
    num_skip_pages = PAGES.count { |page| skip_step?(page) }

    (seen_pages.to_f * 100 / (PAGES.count - num_skip_pages)).round
  end

  def flow_attributes
    Hash[FIELDS.map { |f| [f, send(f)] }]
  end

  def to_cookie
    Base64.encode64(Zlib::Deflate.deflate(JSON.generate(flow_attributes)))
  end

  def ==(other)
    other.flow_attributes == flow_attributes
  end
end
