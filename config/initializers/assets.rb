# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path

# For style guide:
Rails.application.config.assets.paths << Rails.root.join('app', 'assets', 'components')
ActionController::Base.append_view_path(Rails.root.join('app', 'assets', 'components'))

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w(styleguide.css sandbox.css)
