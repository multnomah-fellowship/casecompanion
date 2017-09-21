# frozen_string_literal: true

module DataImporter
  module Connections
    # Designed to look kind of like ActiveRecord, but not enough that it's
    # confusing (hopefully).
    #
    # We can't use activerecord-sqlserver-adapter here because the SQL Server
    # version is too old (2000) and the version of the adapter that supports it
    # was made for Rails 2.3.
    class Crimes
      class << self
        def execute(query)
          case connection.class.name
          when 'PG::Connection'
            connection.query(query)
          when 'TinyTds::Client'
            connection.execute(query)
          end
        end

        def connection
          resolver = ActiveRecord::ConnectionAdapters::ConnectionSpecification::Resolver.new({})
          config = resolver.resolve(ENV['CRIMES_DATABASE_URL'])

          @_connection ||= case config.delete('adapter')
                           when 'sqlserver'
                             require 'tiny_tds'
                             TinyTds::Client.new(**config.symbolize_keys)
                           when 'postgresql'
                             require 'pg'

                             PG.connect(
                               host: config.delete('host'),
                               user: config.delete('username'),
                               password: config.delete('password'),
                               dbname: config.delete('database'),
                             )
                           end
        end
      end
    end
  end
end
