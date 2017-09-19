# frozen_string_literal: true

class FaqsController < ApplicationController
  before_action :set_faq_menu

  FAQ_MENU = [
    # What to expect
    {
      header: { text: helpers.t('faqs.menu.header_1') },
      items: [
        # the value of "faq" should correspond to an I18n key under faqs, e.g.
        # :before_trial will be found at t('faqs.before_trial')
        { text: helpers.t('faqs.menu.section_1.item_1'), faq: :after_reporting },
        { text: helpers.t('faqs.menu.section_1.item_2'), faq: :trial_overview },
        { text: helpers.t('faqs.menu.section_1.item_3'), faq: :overview },
        { text: helpers.t('faqs.menu.section_1.item_4'), faq: :community_supervision },
        { text: helpers.t('faqs.menu.section_1.item_5'), faq: :prison_jail },
      ],
    },
    # Victims' Rights
    {
      header: { text: helpers.t('faqs.menu.header_2') },
      items: [
        { text: helpers.t('faqs.menu.section_2.item_1'), faq: :general_rights },
        { text: helpers.t('faqs.menu.section_2.item_2'), faq: :notification },
        { text: helpers.t('faqs.menu.section_2.item_3'), faq: :financial_assistance },
        { text: helpers.t('faqs.menu.section_2.item_4'), faq: :privacy_protection },
        { text: helpers.t('faqs.menu.section_2.item_5'), faq: :special_cases },
      ],
    },
    # Directories
    {
      header: { text: helpers.t('faqs.menu.header_3') },
      items: [
        { text: helpers.t('faqs.menu.section_3.item_1'), faq: :community_services },
        { text: helpers.t('faqs.menu.section_3.item_2'), faq: :justice_system_services },
      ],
    },
  ].freeze

  def index; end

  def show
    redirect_to faqs_path
  end

  private

  def set_faq_menu
    @faq_menu = FAQ_MENU
  end
end
