# frozen_string_literal: true

class BetaSignupsController < ApplicationController
  def new
    @beta_signup = BetaSignup.new(
      utm_attribution: UtmAttribution.new_from_params(params),
    )

    render layout: 'lander'
  end

  def create
    @beta_signup = BetaSignup.create(beta_signup_params)

    send_signup_to_slack(@beta_signup)
  end

  private

  def beta_signup_params
    params.fetch(:beta_signup, {})
      .permit(:email, utm_attribution_attributes: UtmAttribution::FIELDS)
  end

  def send_signup_to_slack(beta_signup)
    Timeout.timeout(5) do
      slack_response =
        Rails.application.config.slack_client.post_beta_signup_message(beta_signup)

      if slack_response[:error]
        raise StandardError, "Error sending beta_signup to Slack: #{slack_response[:error]}"
      end
    end
  rescue => ex
    Raven.capture_exception(ex)
  end
end
