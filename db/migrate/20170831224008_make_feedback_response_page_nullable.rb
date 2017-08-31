# frozen_string_literal: true

class MakeFeedbackResponsePageNullable < ActiveRecord::Migration[5.0]
  def change
    change_column :feedback_responses, :page, :string, null: true, default: nil

    # backfill existing VRN email feedback responses to have the correct page name
    utm_attribution = UtmAttribution.where(
      utm_campaign: 'vrn_receipt',
      utm_source: 'rights_mailer',
      utm_medium: 'email',
    ).first_or_create

    FeedbackResponse.where(page: %w[vrn-confirmation vrn-experiment]).find_all do |response|
      response.update_attributes(
        page: 'vrn_receipt',
        utm_attribution: utm_attribution,
      )
    end
  end
end
