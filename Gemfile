# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read(File.expand_path('../.ruby-version', __FILE__)).strip

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Rails and its asset compilation dependencies
gem 'autoprefixer-rails'
gem 'coffee-rails', '~> 4.2'
gem 'puma', '~> 3.0'
gem 'rails', '~> 5'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'

# Other Rails dependencies
gem 'bcrypt', '~> 3.1.7'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'turbolinks', '~> 5'

# Dependencies we have added
gem 'ahoy_email'
gem 'delayed_job_active_record', '>= 4.1.3'
gem 'dotenv-rails'
gem 'flipper'
gem 'font-awesome-rails'
gem 'haml', '> 5.0.0'
gem 'inline_svg'
gem 'materialize-sass'
gem 'mixpanel-ruby'
gem 'oos_mechanizer', git: 'https://github.com/tdooner/oos-mechanizer.git'
gem 'prawn'
gem 'premailer-rails'
gem 'sentry-raven'
gem 'sitemap_generator'
gem 'whenever'

group :development, :test do
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'

  # Coverage and Test libraries
  gem 'codeclimate-test-reporter'
  gem 'rspec-html-matchers'
  gem 'rspec-rails'
  gem 'simplecov'
  gem 'spring-commands-rspec'
  gem 'webmock'

  # Linters, et al.:
  gem 'rubocop'

  # Needed by travis-ci:
  gem 'rake'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
end

group :development do
  # Rails's development dependencies
  gem 'listen', '~> 3.0.5'
  gem 'pry'
  gem 'pry-rails'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'

  # Deploy commands
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
  gem 'capistrano-rbenv-install'
end

group :production do
  gem 'pg'
  gem 'tiny_tds', '~> 2.1.0.pre'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
