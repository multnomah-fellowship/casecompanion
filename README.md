# myadvocate ![Build Status](https://travis-ci.org/multnomah-fellowship/myadvocate.svg?branch=master)
Prototype for CfA multnomah fellowship

* [View Live Site](https://myadvocateoregon.org)
* [View Staging Site](https://staging.myadvocateoregon.org)

## useful development links

* [Edit Website Copy](https://github.com/multnomah-fellowship/myadvocate/edit/master/config/locales/en.yml)
* [Heroku Deployment Pipeline](https://dashboard.heroku.com/pipelines/271e11fe-1847-47d2-867a-d19bd13998f3)

## configuration
Make sure to export the following environment variables:

* `FRONT_WEB_TOKEN`
* `TWILIO_PHONE_NUMBER` (e.g. '+11234567890')
* `APP_DOMAIN` (e.g. `myadvocateoregon.org`. This domain must have valid TLS!)

To send email you will additionally need the following settings:

* `SMTP_HOSTNAME` (e.g. 'smtp.mailgun.org')
* `SMTP_USERNAME` (e.g. 'postmaster@mail.myadvocateoregon.org')
* `SMTP_PASSWORD` (e.g. '12345')

## installation
```bash
# install ruby 2.4.0 (or whatever version is specified in .ruby-version)
brew install rbenv
rbenv install
gem install bundler

# install application dependencies
bundle install

# copy configuration template
cp .env.development .env

# start the app:
bin/rails server
```

## running tests
To run tests, run `bin/rspec [filename of a single test]`

You may have to set up your database first with `bin/rake db:test:prepare`.
