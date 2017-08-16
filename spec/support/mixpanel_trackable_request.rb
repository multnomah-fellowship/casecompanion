def mixpanel_trackable_request(distinct_id = 'THISISMYDISTINCTID')
  env = {
    MixpanelMiddleware::DISTINCT_ID => distinct_id,
    'remote_ip' => '::1',
  }

  ActionDispatch::Request.new(env)
end
