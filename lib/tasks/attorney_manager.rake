# frozen_string_literal: true

namespace :attorney_manager do
  task importer: :environment do
    @logger = SqlTableLogger.new(ENV['LOCAL_ATTORNEY_MANAGER_DATABASE_URL'], 'attorney_manager_import_log')
    @logger.reset!
    @destination = LocalAttorneyManagerInPostgres.new
    @importer = AttorneyManagerImporter.new(
      url: ENV['ATTORNEY_MANAGER_DATABASE_URL'],
      logger: @logger,
      destination: @destination
    )
  end

  desc 'Import all data from Attorney Manager into local database'
  task import_all: %i[importer] do
    @logger.capture_rails_logger do
      Rails.logger.info 'Preparing for Attorney Manager import'
      Rails.logger.info '  Recreating local schema...'
      @importer.drop_and_recreate_local!

      Rails.logger.info 'Starting Attorney Manager import'
      @importer.import_all

      Rails.logger.info 'Finished Attorney Manager import successfully!'
    end
  end
end
