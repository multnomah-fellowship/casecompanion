# frozen_string_literal: true

# config valid only for current version of Capistrano
lock '3.9.0'

set :application, 'casecompanion'
set :repo_url, 'https://github.com/multnomah-fellowship/casecompanion.git'
set :deploy_to, '/home/app'
set :default_env, APP_DOMAIN: 'localhost'
set :systemd_web_service, 'casecompanion'
set :systemd_worker_service, 'casecompanion-worker'
set :rbenv_ruby, File.read(File.expand_path('../../.ruby-version', __FILE__)).strip
set :branch, ENV['BRANCH'] && ENV['BRANCH'].length ? ENV['BRANCH'] : 'master'

# TODO: Make Ansible use Capistrano's default
set :repo_path, -> { "#{fetch(:deploy_to)}/scm" }

set :linked_files, %w[config/database.yml .env]
set :linked_dirs, %w[log tmp/pids tmp/cache tmp/sockets]

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true,
#   log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5
