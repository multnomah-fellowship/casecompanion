class BetaSignupsController < ApplicationController
  def new
    @beta_signup = BetaSignup.new(
      utm_attribution: UtmAttribution.new_from_params(params)
    )

    render layout: 'lander'
  end

  def create
    @beta_signup = BetaSignup.create(beta_signup_params)
  end

  private

  def beta_signup_params
    params.fetch(:beta_signup, {})
      .permit(:email, utm_attribution_attributes: UtmAttribution::FIELDS)
  end
end
