# frozen_string_literal: true

require 'pg'

# CRIMES dump gets imported into a local Postgres database. This class attempts
# to keep the responsibility of managing the connection and interactions with
# the PG gem.
class LocalCrimesInPostgres
  def initialize(url: ENV['LOCAL_CRIMES_DATABASE_URL'])
    resolver = ActiveRecord::ConnectionAdapters::ConnectionSpecification::Resolver.new({})
    config = resolver.resolve(url)

    @client = PG.connect(
      dbname: config['database'],
      host: config['host'],
      port: config['port'],
      user: config['username'],
      password: config['password'],
    )
  end

  def load_schema_file!(filename)
    @client.exec(File.read(filename))
  end

  def import_into_table(table)
    encoder = PG::TextEncoder::CopyRow.new
    @client.copy_data("COPY #{table} FROM STDIN", encoder) do
      yield TableImporter.new(@client)
    end
  end

  def export_query_as_csv(query)
    return to_enum(:export_query_as_csv, query) unless block_given?

    @client.copy_data("COPY (#{query}) TO STDOUT CSV DELIMITER ',' HEADER;") do
      while (row = @client.get_copy_data)
        yield row.encode('utf-8', invalid: :replace, undef: :replace)
      end
    end
  end

  # Private Class
  class TableImporter
    def initialize(client)
      @client = client
    end

    def <<(row)
      @client.put_copy_data row
    end
  end
end
