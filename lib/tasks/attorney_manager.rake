# frozen_string_literal: true

namespace :attorney_manager do
  task importer: :environment do
    @logger = SqlTableLogger.new(ENV['LOCAL_ATTORNEY_MANAGER_DATABASE_URL'], 'attorney_manager_import_log')
    @logger.reset!
    @logger.capture_rails_logger do
      @destination = LocalAttorneyManagerInPostgres.new
      @importer = AttorneyManagerImporter.new(
        destination: @destination
      )
    end
  end

  desc 'Import all data from Attorney Manager into local database'
  task import_all: %i[importer] do
    @importer.import_all
  end
end
