# frozen_string_literal: true

namespace :attorney_manager do
  task importer: :environment do
    @logger = SqlTableLogger.new(ENV['LOCAL_ATTORNEY_MANAGER_DATABASE_URL'], 'attorney_manager_import_log')
    @logger.reset!
    @destination = LocalAttorneyManagerInPostgres.new
    @importer = AttorneyManagerImporter.new(
      destination: @destination
    )
  end

  desc 'Import all data from Attorney Manager into local database'
  task import_all: %i[importer] do
    @logger.capture_rails_logger do
      Rails.logger.info 'Beginning Attorney Manager import'
      @importer.import_all
      Rails.logger.info 'Finished Attorney Manager import successfully!'
    end
  end
end
