# myadvocate
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
