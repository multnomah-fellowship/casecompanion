# frozen_string_literal: true

namespace :crimes_import do
  task importer: :environment do
    Rails.logger = Logger.new($stderr) if Rails.env.development?

    @importer = CrimesImporter.new(
      logger: Rails.logger,
      destination: LocalCrimesInPostgres.new,
    )
  end

  task drop_temp_tables: :importer do
    Rails.logger.info('Dropping temporary tables...')
    @importer.drop_temp_tables
  end

  task create_indices: :importer do
    Rails.logger.info('Creating indices...')
    @importer.create_indices
  end

  desc 'Drop and recreate the temporary tables without exporting anything locally'
  task recreate_temp_tables: %i[drop_temp_tables create_indices] do
    Rails.logger.info('Creating temporary tables...')
    @importer.create_temp_tables
  end

  desc 'Import all data into local database'
  task import_all: %i[recreate_temp_tables] do
    Rails.logger.info('Beginning import...')

    @importer.import_all
  end

  # DEBUGGING INFO:
  task help_connecting: :environment do
    next if Rails.env.production? # It's only meant to be helpful in development

    puts <<-INFO.strip_heredoc
      This script will help you try to debug connection problems to CRIMES
      assuming you are connecting through an SSH tunnel to set up connections
      like so:

      Local Machine --(RDP)--> Windows ---(TCP)---> CRIMES
                    <--(SSH)--

    INFO

    # Verify configuration of CRIMES_DATABASE_URL
    config = nil
    begin
      unless ENV['CRIMES_DATABASE_URL'].present?
        raise 'Empty or undefined value for CRIMES_DATABASE_URL'
      end

      unless ENV['LOCAL_CRIMES_DATABASE_URL'].present?
        raise 'Empty or undefined value for LOCAL_CRIMES_DATABASE_URL'
      end

      resolver = ActiveRecord::ConnectionAdapters::ConnectionSpecification::Resolver.new({})
      config = resolver.resolve(ENV['CRIMES_DATABASE_URL'])

      unless config['host'] == 'localhost'
        raise 'CRIMES_DATABASE_URL host should be "localhost" to use local SSH tunnel'
      end
    rescue => ex
      puts <<-ERROR.strip_heredoc
        It looks like CRIMES_DATABASE_URL might be configured incorrectly:

        #{ex.message}

        It should look something like:

          sqlserver://mcda%5Cyourusername:yourpassword@localhost:2612/Crimsadl
            ?tds_version=7.1&dataserver=localhost:2612%5Cmssql%24dada2
      ERROR
      next
    end

    vpn_ip = Socket.ip_address_list.detect { |addr| addr.ip_address.start_with?('172.') }
    unless vpn_ip
      puts <<-ERROR.strip_heredoc
        There was an error finding your VPN IP address. Make sure you are
        connected to Multnomah County VPN
      ERROR
      next
    end

    begin
      ssh_socket = TCPSocket.new('127.0.0.1', 22)
      ssh_banner = ssh_socket.read(3)
      raise unless ssh_banner == 'SSH'
      ssh_socket.close
    rescue
      puts <<-ERROR.strip_heredoc
        It looks like you're not running SSH locally. On Mac, you can enable this in:

          System Preferences > Sharing > Remote Login
      ERROR
      next
    end

    begin
      # Look to see if the SSH remote tunnel is open
      TCPSocket.new('127.0.0.1', config['port'].to_i).close
    rescue
      puts <<-ERROR.strip_heredoc
        Could not connect to SSH tunnel. You may need to start it on the remote machine
        with this command:

        ssh -R#{config['port']}:dacry2.mcda.mccj.local:2612 #{ENV['USER']}@#{vpn_ip.ip_address}
      ERROR
      next
    end

    # Finally, check if the connection is successful.
    destination = nil
    begin
      destination = LocalCrimesInPostgres.new
    rescue => ex
      puts <<-ERROR.strip_heredoc
      There was an error connecting to the LOCAL_CRIMES_DATABASE_URL:

      #{ex.message}
      ERROR
      next
    end

    CrimesImporter.new(destination: destination)
    puts 'Connection successful!'
  end
end
