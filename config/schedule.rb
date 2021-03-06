# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
set :path, '/home/app/current'
set :output, File.expand_path("../../log/#{ENV['RAILS_ENV'] || 'development'}.log", __FILE__)

every 24.hours, at: '10:00', on: %i[db] do # 3 AM PDT = 10:00 UTC
  rake 'attorney_manager:import_all'
end

# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
