class User < ActiveRecord::Base
  has_secure_password validations: false

  has_many :court_case_subscriptions
end
