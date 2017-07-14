# frozen_string_literal: true

class BetaSignupsMailerPreview < ActionMailer::Preview
  def beta_signup_created
    BetaSignupsMailer.beta_signup_created(sample_signup)
  end

  private

  def sample_signup
    BetaSignup.new(
      email: 'tomdooner@gmail.com',
      utm_attribution: UtmAttribution.new(
        utm_campaign: 'some_campaign',
        utm_content: 'some_content',
      ),
    )
  end
end
