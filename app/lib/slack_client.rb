class SlackClient
  def initialize(hook_url: ENV['SLACK_WEBHOOK_URL'], app_name: 'MyAdvocate Development')
    @hook_url = hook_url
    @app_name = app_name
  end

  def post_feedback_message(feedback)
    return { error: 'No Webhook Specified' } unless @hook_url.present?

    feedback_attachment = {
      attachments: [
        {
          fallback: "New feedback submitted: #{feedback.body}",
          color: '#2f6296', # color: multnomah-blue
          pretext: 'New Feedback Submitted to MyAdvocate',
          text: feedback.body,
          fields: [
            {
              title: "Value",
              value: feedback.value,
              short: true
            },
            {
              title: "Page",
              value: feedback.page,
              short: true
            }
          ],
          footer: @app_name,
          ts: feedback.created_at.to_i,
        }
      ]
    }

    slack_uri = URI(@hook_url)
    Net::HTTP.start(slack_uri.host, slack_uri.port, use_ssl: true) do |http|
      req = Net::HTTP::Post.new(slack_uri.request_uri)
      req['Content-Type'] = 'application/json'
      req.body = JSON.generate(feedback_attachment)

      resp = http.request(req)
      if resp.code.to_i < 300
        return { success: true }
      else
        return { error: "Slack Request Failed (code #{resp.code}): #{resp.body}" }
      end
    end
  end
end
