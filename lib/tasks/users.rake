# frozen_string_literal: true

namespace :users do
  desc 'Create an administrator login'
  task create_admin: :environment do
    require 'io/console'

    puts 'Administrator Email: '
    email = $stdin.gets.strip

    password_confirmed = false

    until password_confirmed
      puts 'Password: '
      password = $stdin.noecho(&:gets).strip

      puts 'Password (Confirm): '
      password_confirmed = $stdin.noecho(&:gets).strip == password
    end

    user = User.create(
      email: email,
      password: password,
    )

    if user
      puts 'User creation succeeded!'
    else
      puts 'User creation failed :('
    end
  end
end
