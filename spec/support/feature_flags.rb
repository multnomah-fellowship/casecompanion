# frozen_string_literal: true

def enable_feature(name, example)
  Rails.application.config.flipper[name].enable
  example.run
  Rails.application.config.flipper[name].disable
end
