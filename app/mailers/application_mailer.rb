# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'Case Companion Team <team@casecompanion.org>'
  layout 'mailer'

  def remove_feedback_section!
    @remove_feedback_section = true
  end
end
