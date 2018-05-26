require 'tiny_tds'

# This class contains the logic for importing data from the Attorney Manager
# product (to be launched in Summer 2018) to supercede the CRIMES database.
#
# To test this locally, assuming you are not able to access the database
# directly (e.g. if you do not have county-provisioned hardware), you will have
# to set up a tunnel between wherever the CRIMES database is and your
# development machine.
#
# For me, the way to do this is to first VPN into Multnomah County and then
# Remote Desktop into a Windows VM on which I have installed Git for Windows.
# Git for Windows includes an SSH client, and we can use that to connect back to
# an SSH Server running on the development machine.
#
# On Mac, set up an SSH server like so:
#   System Preferences > Sharing > Remote Login > Enable
# On Windows 10, follow these instructions to use Windows's built-in SSH server:
#   https://www.bleepingcomputer.com/news/microsoft/how-to-install-the-built-in-windows-10-openssh-server/
#
# After SSH is running, set up a remote forwarding tunnel from the Windows VM
# with this command:
#
#   bin/mcda-setup-dev-ssh-tunnel
#
# Then, on your local development machine, set the environment variable
# ATTORNEY_MANAGER_DATABASE_URL to:
#
#   sqlserver://mcda%5Cdoonerto:[password]@localhost:51123/Justice?dataserver=localhost:51123%5CMCDA-AMSQLDEV%24TEST
#
class AttorneyManagerImporter
  # Create a new connection to Attorney Manager
  #
  # @param String url
  # @param Logger logger
  # @param LocalCrimesInPostgres destination An object supporting methods used
  #   to load and dump data.
  def initialize(url: ENV['ATTORNEY_MANAGER_DATABASE_URL'], logger: Rails.logger, destination:)
    resolver = ActiveRecord::ConnectionAdapters::ConnectionSpecification::Resolver.new({})
    config = resolver.resolve(url)

    config['timeout'] ||= 900 # seconds

    @client = TinyTds::Client.new(**config.symbolize_keys)
    @logger = logger
    @destination = destination
  end

  def drop_and_recreate_local!
    @destination.load_schema_file!(Rails.root.join('deploy', 'attorneymanager-etl', 'local-schema.sql'))
  end

  def import_all
    @destination.import_into_table('victim_cases') do |table|
      execute_file_or_query(Pathname.new('deploy/attorneymanager-etl/queries/01_victims.sql')) do |row|
        table << row.values
      end
    end
  end

  private

  def execute_file_or_query(query_file_or_string, &block)
    query = case query_file_or_string
            when Pathname
              @logger.debug "Executing query in #{File.basename(query_file_or_string)}"

              load_file(query_file_or_string)
            when String
              @logger.debug "Executing query #{query_file_or_string.truncate(40)}"

              query_file_or_string
            else
              raise 'Unexpected input to #exceute_file_or_query (must be Pathname or String)'
            end

    start_time = Time.now

    result = @client.execute(query)

    elapsed_time = Time.now - start_time
    @logger.debug "  got results in #{elapsed_time}"

    if block_given?
      result.each(&block)
    else
      result.do
    end
  end

  def load_file(filename)
    File.read(Rails.root.join(filename))
  end
end
