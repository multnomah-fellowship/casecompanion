# frozen_string_literal: true

class BetaSignupsMailer < ApplicationMailer
  layout nil

  def beta_signup_created(signup)
    @signup = signup

    mail(
      to: @signup.email,
      subject: 'Thanks from MyAdvocate',
    )
  end
end
