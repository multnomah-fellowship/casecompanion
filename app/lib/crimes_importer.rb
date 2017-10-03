# frozen_string_literal: true

require 'tiny_tds'

# This class contains the logic for a series of queries against the CRIMES case
# tracking database SQL Server replica. Although a Rails-idiomatic approach
# would be to model the data with ActiveRecord, we can't use
# activerecord-sqlserver-adapter here because the SQL Server version is too old
# (2000) and the version of the adapter that supports it was made for Rails 2.3.
#
# So hence this class, which contains the raw connection and results processing
# logic.
class CrimesImporter
  # To test this locally, you will have to set up a tunnel between wherever the
  # CRIMES database is and your development machine.
  #
  # For me, the way to do this is to first VPN into Multnomah County. Since I'm
  # not using an IT-managed laptop, I cannot access CRIMES directly. However, I
  # can access a Windows VM which I have installed Git for Windows which
  # includes an SSH client. So by setting up an SSH server on my Mac (System
  # Preferences > Sharing > Remote Login > Enable), I am able to set up a remote
  # forwarding tunnel from the Windows VM with this command:
  #
  #   ssh -R 2612:[crimes_host]:2612 Tom@[VPN IP address]
  #
  # (I'm not sure why CRIMES is running on port 2612.)
  #
  # Then, I can set the CRIMES_DATABASE_URL environment variable like so to use
  # that connection:
  #
  #   sqlserver://mcda%5Cdoonerto:[password]@localhost:2612/Crimsadl?
  #     tds_version=7.1&dataserver=localhost:2612%5Cmssql%24dada2
  #
  # (make sure to URL encode your username, password, and query string params)
  def initialize(url: ENV['CRIMES_DATABASE_URL'], logger: Logger.new($stderr))
    resolver = ActiveRecord::ConnectionAdapters::ConnectionSpecification::Resolver.new({})
    config = resolver.resolve(url)

    config['timeout'] ||= 300 # seconds

    @client = TinyTds::Client.new(**config.symbolize_keys)
    @logger = logger
  end

  def drop_temp_tables
    %w[
      CFA_TOM_VRN CFA_TOM_PROBATION CFA_TOM_RESTITUTION CFA_TOM_VICTIM_LATEST_ADDRESS
      CFA_TOM_VICTIM_INFO CFA_TOM_DEFENDANT_INFO
    ].each do |table_name|
      @logger.info "Dropping table #{table_name}"

      begin
        @client.execute("DROP TABLE #{table_name};").do
      rescue => ex
        raise ex unless ex.message.match?(/it does not exist in the system catalog/)
      end
    end
  end

  # rubocop:disable Metrics/LineLength
  def create_indices
    {
      'cfa_tom_case_person' =>
        'CREATE INDEX cfa_tom_case_person ON CASE_PERSON (CASE_ID_NBR, CASE_PERSON_TYPE, PERSON_ID_NBR)',
      'cfa_tom_cp_address' =>
        'CREATE INDEX cfa_tom_cp_address ON CASE_PERSON_ADDRESS (PERSON_ID_NBR, SUB_ONLY, ALL_DOCS);',
      'cfa_tom_cp_phone' =>
        'CREATE INDEX cfa_tom_cp_phone ON CASE_PERSON_PHONE (PERSON_ID_NBR, DEFAULT_PHONE);',
      'cfa_tom_cp_info' =>
        'CREATE INDEX cfa_tom_cp_info ON CASE_PERSON_INFO (PERSON_ID_NBR);',
      'cfa_tom_case_main' =>
        'CREATE INDEX cfa_tom_case_main ON CASE_MAIN (CASE_ID_NBR);',
      'cfa_tom_cp_flag' =>
        'CREATE INDEX cfa_tom_cp_flag ON CASE_FLAG (CASE_ID_NBR, PERSON_ID_NBR);',
    }.each do |index_name, create_statement|
      @logger.info "Creating index (if it doesn't exist): #{index_name}"

      @client.execute(<<-SQL)
        IF NOT EXISTS (SELECT * FROM sysindexes WHERE name = '#{index_name}') BEGIN
        #{create_statement}
        END
      SQL
    end
  end
  # rubocop:disable Metrics/LineLength

  # TODO: break this into two parts -- one that creates the tmp tables (01*.sql
  # files) and one that dumps the results to CSV
  def import_all
    %w[
      deploy/crimes-etl/queries/01a_TMP_VRN.sql
      deploy/crimes-etl/queries/01b_TMP_RESTITUTION.sql
      deploy/crimes-etl/queries/01c_TMP_PROBATION.sql
      deploy/crimes-etl/queries/01d_TMP_VICTIM_INFO.sql
      deploy/crimes-etl/queries/01e_TMP_DEFENDANT_INFO.sql
      deploy/crimes-etl/queries/02_VICTIM_NAME.sql
      deploy/crimes-etl/queries/03_VRN.sql
      deploy/crimes-etl/queries/04_CASE_INFO.sql
    ].each do |query_file|
      query = File.read(File.expand_path(File.join('../../', query_file)))

      @logger.info "Executing query in #{File.basename(query_file)}..."
      @client.execute(query)
    end
  end
end
