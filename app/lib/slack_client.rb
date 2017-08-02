# frozen_string_literal: true

class SlackClient
  def initialize(hook_url: ENV['SLACK_WEBHOOK_URL'], app_name: 'Case Companion Dev')
    @hook_url = hook_url
    @app_name = app_name
    @disabled = false
  end

  # Disable messages within a certain bit of code. Meant for use in tests, e.g.
  #
  # ```
  # around do |ex|
  #   Rails.application.config.slack_client.disable_messages! { ex.run }
  # end
  # ```
  def disable_messages!
    previous_disabled = @disabled
    @disabled = true
    yield
  ensure
    @disabled = previous_disabled
  end

  def post_beta_signup_message(beta_signup)
    return { error: 'No Webhook Specified' } unless @hook_url.present?

    attribution_fields =
      beta_signup.utm_attribution
        .try(:slice, *UtmAttribution::FIELDS)
        .try(:find_all) { |_k, v| v.present? }
        .try(:map) { |k, v| { title: k, value: v, short: true } }
        .to_a

    beta_signup_attachment = {
      attachments: [
        {
          fallback: "New beta signup: #{beta_signup.email}",
          color: '#2f6296', # color: multnomah-blue
          pretext: 'New Beta Signup!',
          fields: [
            {
              title: 'Email',
              value: beta_signup.email,
              short: true,
            },
          ] + attribution_fields,
          footer: @app_name,
          ts: beta_signup.created_at.to_i,
        },
      ],
    }

    send_message(beta_signup_attachment)
  end

  def post_feedback_message(feedback)
    return { error: 'No Webhook Specified' } unless @hook_url.present?

    feedback_attachment = {
      attachments: [
        {
          fallback: "New feedback submitted: #{feedback.body}",
          color: '#2f6296', # color: multnomah-blue
          pretext: 'New Feedback Submitted to Case Companion',
          text: feedback.body,
          fields: [
            {
              title: 'Value',
              value: feedback.value,
              short: true,
            },
            {
              title: 'Page',
              value: feedback.page,
              short: true,
            },
          ],
          footer: @app_name,
          ts: feedback.created_at.to_i,
        },
      ],
    }

    send_message(feedback_attachment)
  end

  private

  def send_message(attachment)
    return { success: true, disabled: true } if @disabled

    slack_uri = URI(@hook_url)
    Net::HTTP.start(slack_uri.host, slack_uri.port, use_ssl: true) do |http|
      req = Net::HTTP::Post.new(slack_uri.request_uri)
      req['Content-Type'] = 'application/json'
      req.body = JSON.generate(attachment)

      resp = http.request(req)
      return { success: true } if resp.code.to_i < 300
      return { error: "Slack Request Failed (code #{resp.code}): #{resp.body}" }
    end
  end
end
