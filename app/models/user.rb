class User < ActiveRecord::Base
  has_secure_password

  has_many :court_case_subscriptions
end
