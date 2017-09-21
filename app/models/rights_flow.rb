# frozen_string_literal: true

# This model is not persisted in the database!
# Rather, it accumulates state on each page of the flow, and at the end of the
# flow, the #persist! method is called, at which time it creates related
# objects.
# rubocop:disable Metrics/ClassLength
class RightsFlow
  include ActiveModel::Model
  include ActiveModel::AttributeMethods
  extend ActiveModel::Translation

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
    advocate_email
    court_case_subscription_id
    completed_step
    electronic_signature_checked
    electronic_signature_name
    dda_email
  ].freeze

  # The ordered steps of the flow, all of which will be the `id` in the route
  # /rights/:id
  PAGES = %w[
    who_assert
    to_notification
    to_financial_assistance
    in_special_cases
    create_account
    confirmation
    done
  ].freeze

  attr_accessor :current_page
  attr_accessor(*FIELDS)
  attr_reader :errors

  def initialize(*)
    @errors = ActiveModel::Errors.new(self)
    super
  end

  # rubocop:disable Metrics/AbcSize
  def validate!
    case current_page
    when 'create_account'
      unless court_case_subscription_id.present?
        errors.add(:first_name, :blank) unless first_name.present?
        errors.add(:last_name, :blank) unless last_name.present?
        errors.add(:case_number, :blank) unless case_number.present?
        errors.add(:advocate_email, :blank) unless advocate_email.present?
        errors.add(:dda_email, :blank) unless dda_email.present?
      end

      if case_number.present?
        case case_number
        when /\d+CR\d+/i
          errors.add(:case_number, 'should be the DA case number')
        when /[[:alpha:]]/
          errors.add(:case_number, 'cannot contain letters')
        end
      end
    when 'confirmation'
      unless electronic_signature_checked == '1'
        errors.add(:electronic_signature_checked, 'must be checked')
      end

      unless electronic_signature_name.strip.casecmp("#{first_name} #{last_name}").zero?
        errors.add(:electronic_signature_name, "must match \"#{first_name} #{last_name}\"")
      end
    end

    assign_attributes(completed_step: current_page) if errors.none?
  end
  # rubocop:enable Metrics/AbcSize

  def persist!
    checked_rights =
      flow_attributes
        .find_all { |attr, _value| Right::RIGHTS.include?(attr.to_sym) }
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
      advocate_email: advocate_email,
      dda_email: dda_email,
    )

    if subscription.persisted? &&
        subscription.rights_hash != previous_rights_hash
      subscription.touch
    end

    subscription.save

    self.court_case_subscription_id = subscription.id
  end

  def just_created?
    return false unless court_case_subscription_id
    subscription = CourtCaseSubscription.find(court_case_subscription_id)
    return false unless subscription

    subscription.created_at == subscription.updated_at
  end

  # @param right {String} The key from Right::RIGHTS, e.g. :flag_a
  def right_selected?(right)
    return unless respond_to?(right)

    %w[true 1].include?(send(right))
  end

  def current_progress_chunks
    case current_page
    when 'who_assert'
      0
    when 'to_notification'
      0
    when 'to_financial_assistance'
      1
    when 'in_special_cases'
      2
    when 'create_account'
      3
    when 'confirmation'
      3
    when 'done'
      3
    end
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

  def redirect_to_page
    # if the user is on the first step, don't redirect them
    return if current_page == RightsFlow.first_step

    # if the user is on a page before or including the page after the last
    # completed step, don't redirect them
    completed_step_index = PAGES.find_index(completed_step || RightsFlow.first_step)
    return if PAGES.find_index(current_page) <= completed_step_index + 1

    # otherwise, they need to be redirected
    #   if they haven't completed any steps yet, get them back to the beginning
    return self.class.first_step unless completed_step

    PAGES[PAGES.find_index(completed_step) + 1]
  end

  def finished?
    next_step == PAGES[-1]
  end

  def previous_step
    i = PAGES.find_index(current_page)
    return if i.zero?

    PAGES[[0, i - 1].max]
  end

  def next_step
    PAGES[PAGES.find_index(current_page) + 1]
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
