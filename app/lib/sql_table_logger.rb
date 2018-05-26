# Logger class that saves its lines in a database table
class SqlTableLogger < Logger
  TABLE_DROP_QUERY = 'DROP TABLE IF EXISTS %{table_name}'
  TABLE_READ_QUERY = 'SELECT * FROM %{table_name}'
  TABLE_CREATE_QUERY = <<-SQL
  CREATE TABLE %{table_name} (
    level character varying(5) not null,
    body text
  );
  SQL
  TABLE_INSERT_QUERY = 'INSERT INTO %{table_name} (level, body) VALUES ($1, $2)'

  def initialize(url, table_name)
    resolver = ActiveRecord::ConnectionAdapters::ConnectionSpecification::Resolver.new({})
    config = resolver.resolve(url).with_indifferent_access

    @table_name = table_name
    @client = PG.connect(
      dbname: config['database'],
      host: config['host'],
      port: config['port'],
      user: config['username'],
      password: config['password'],
    )
    @prepared = false
  end

  def lines
    @client.exec(format_query(TABLE_READ_QUERY)).to_a
  end

  def reset!
    @client.exec(format_query(TABLE_DROP_QUERY))
    @client.exec(format_query(TABLE_CREATE_QUERY))
  end

  def <<(message)
    add(Logger::UNKNOWN, message, nil)
  end

  def add(severity, message = nil, progname = nil)
    unless @prepared
      @client.prepare('insert_row', format_query(TABLE_INSERT_QUERY))
      @prepared = true
    end

    # the superclass's add method is a hot mess, copy a few pieces of its logic
    # here:
    if message.nil?
      message = progname
    end

    # write the row
    @client.exec_prepared('insert_row', [format_severity(severity), message])
  end

  # Within the passed block, capture anything logged to Rails.logger
  def capture_rails_logger(&block)
    original = Rails.logger.dup

    Rails.logger.extend(ActiveSupport::Logger.broadcast(self))

    block.call
  ensure
    Rails.logger = original
  end

  private

  def format_query(query)
    query % {
      table_name: @client.escape_string(@table_name)
    }
  end
end
