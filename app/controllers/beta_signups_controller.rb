# frozen_string_literal: true

require 'csv'

class BetaSignupsController < ApplicationController
  def new
    @beta_signup = BetaSignup.new(
      utm_attribution: UtmAttribution.new_from_params(params),
    )

    render layout: 'lander'
  end

  def create
    @beta_signup = BetaSignup.create(beta_signup_params)

    return render :new, layout: 'lander' if @beta_signup.errors.any?

    @mixpanel.track('beta-signup', email: @beta_signup.email, beta_signup_id: @beta_signup.id)
    send_signup_to_slack(@beta_signup)
    send_email_confirmation(@beta_signup)
  end

  def index
    verify_shared_secret!

    @beta_signups = BetaSignup.all.includes(:utm_attribution)

    return render text: 'No beta signups!' unless @beta_signups.any?

    respond_to do |format|
      format.html
      format.csv
    end
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

  def send_email_confirmation(beta_signup)
    return unless helpers.feature_enabled?('beta_signup_email')

    BetaSignupsMailer
      .beta_signup_created(beta_signup)
      .deliver_now
  end

  def verify_shared_secret!
    if ENV['DOWNLOAD_SECRET'].blank?
      flash[:error] = 'Unconfigured download secret'
      redirect_to root_path
    elsif params[:secret].blank?
      flash[:error] = 'Please use the secret URL parameter to download'
      redirect_to root_path
    elsif params[:secret] != ENV['DOWNLOAD_SECRET']
      flash[:error] = 'Incorrect download secret'
      redirect_to root_path
    end
  end
end
