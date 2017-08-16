# frozen_string_literal: true

# config valid only for current version of Capistrano
lock '3.9.0'

set :application, 'casecompanion'
set :repo_url, 'https://github.com/multnomah-fellowship/casecompanion.git'
set :deploy_to, '/home/app'
set :default_env, APP_DOMAIN: 'localhost'
set :systemd_service, 'casecompanion'
set :rbenv_ruby, File.read(File.expand_path('../../.ruby-version', __FILE__)).strip

# TODO: Make Ansible use Capistrano's default
set :repo_path, -> { "#{fetch(:deploy_to)}/scm" }

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

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5
