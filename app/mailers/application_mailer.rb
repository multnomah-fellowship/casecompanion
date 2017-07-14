# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'MyAdvocate Team <team@myadvocateoregon.org>'
  layout 'mailer'

  def remove_feedback_section!
    @remove_feedback_section = true
  end
end
