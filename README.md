# casecompanion ![Build Status](https://travis-ci.org/multnomah-fellowship/casecompanion.svg?branch=master)
The first public website designed and built for victims of crime regardless of where they are in the justice system.

A product of the CfA Multnomah County Fellowship team.

* [View Live Site](https://casecompanion.org)
* [View Staging Site](https://staging.casecompanion.org)

## useful development links

* [Edit Website Copy](https://github.com/multnomah-fellowship/myadvocate/edit/master/config/locales/en.yml)
* [Heroku Deployment Pipeline](https://dashboard.heroku.com/pipelines/271e11fe-1847-47d2-867a-d19bd13998f3)

## configuration
Make sure to export the following environment variables:

* `APP_DOMAIN` (e.g. `casecocmpanion.org`. This domain must have valid TLS!)
* `VRN_UPDATE_EMAIL_ADDRESS` (e.g. 'tom@example.com') - Destination mailbox for
    VRNs coming out of the digital VRN flow.
* `DCJ_BAXTER_API_KEY` - Required to search probation records.

To send email you will additionally need the following settings:

* `SMTP_HOSTNAME` (e.g. 'smtp.mailgun.org')
* `SMTP_USERNAME` (e.g. 'postmaster@casecompanion.org')
* `SMTP_PASSWORD` (e.g. '12345')

Other optional environment variables that are used for configuration include:

* `GOOGLE_ANALYTICS_SITE_ID` (e.g. 'UA-XXXXXXXXXX-Y')
* `MIXPANEL_TOKEN` (e.g. 'abcdef123.......')
* `ENABLE_INSPECTLET` (e.g. 'true')

## installation
```bash
# install ruby 2.4.0 (or whatever version is specified in .ruby-version)
brew install rbenv freetds
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

## CRIMES integration
Case Companion can fetch data from CRIMES in order to notify victims of case-specific information.

Since the CRIMES database we have access to is a slow analytics replica, the CRIMES code will import data into a local database first. This is done with the `crimes_import:import_all` rake task.

To import the data from CRIMES, you will need the `CRIMES_DATABASE_URL`
environment variable set up. There is some documentation about how to set up a
development environment, and what the value should be in production:

1. `bin/rake crimes_import:help_connecting` will help you set up a development
   environment
2. To create a connection from your development machine to CRIMES (through Remote Desktop + SSH), use the
   `bin/mcda-setup-dev-ssh-tunnel` script.
3. The comments in `app/lib/crimes_importer.rb` have documentation to tie it all together.

Once the data is imported into a local database, you can use it, for example, with:

```bash
bin/rake mailchimp_csvs:generate
```

...which will output mailchimp CSVs in you local `tmp` directory.
