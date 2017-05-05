class FaqsController < ApplicationController
  before_action :set_faq_menu

  FAQ_MENU = [
    # What to expect
    {
      header: { text: helpers.t('faqs.menu.header_1') },
      items: [
        # the value of "faq" should correspond to an I18n key under faqs, e.g.
        # :before_trial will be found at t('faqs.before_trial')
        { text: helpers.t('faqs.menu.section_1.item_1'), faq: :before_trial },
        { text: helpers.t('faqs.menu.section_1.item_2'), faq: :prison_jail },
        { text: helpers.t('faqs.menu.section_1.item_3'), faq: :community_supervision },
        { text: helpers.t('faqs.menu.section_1.item_4'), faq: :financial_assistance },
        { text: helpers.t('faqs.menu.section_1.item_5'), faq: :privacy_protection },
      ],
    },
    # Directories
    {
      header: { text: helpers.t('faqs.menu.header_2') },
      items: [
        { text: helpers.t('faqs.menu.section_2.item_1'), faq: :all_rights },
        { text: helpers.t('faqs.menu.section_2.item_2'), faq: :all_services },
        { text: helpers.t('faqs.menu.section_2.item_3'), faq: :all_pocs },
      ],
    },
  ]

  def index
    redirect_to faq_path(helpers.faq_slug(@faq_menu[0][:items][0]))
  end

  def show
    render :index
  end

  private

  def set_faq_menu
    @faq_menu = FAQ_MENU

    if params[:id]
      @faq_item = helpers.find_faq_item(FAQ_MENU, params[:id])
    end
  end
end