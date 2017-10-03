# frozen_string_literal: true

namespace :users do
  desc 'Create an administrator login'
  task create_admin: :environment do
    require 'io/console'

    puts 'Administrator Email: '
    email = $stdin.gets.strip
    user_exists = User.where(email: email).exists?

    if user_exists
      puts 'Warning: User already exists. Press enter to continue.'
      $stdin.gets
    end

    password_confirmed = false

    until password_confirmed
      puts 'Password: '
      password = $stdin.noecho(&:gets).strip

      puts 'Password (Confirm): '
      password_confirmed = $stdin.noecho(&:gets).strip == password
    end

    user = User
      .where(email: email)
      .first_or_initialize
      .update_attributes(password: password, is_admin: true)

    if user
      puts "User #{user_exists ? 'modification' : 'creation'} succeeded!"
    else
      puts 'User creation failed :('
    end
  end
end
