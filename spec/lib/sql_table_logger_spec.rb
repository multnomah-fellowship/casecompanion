require 'rails_helper'

RSpec.describe SqlTableLogger do
  # Not technically a URL, but it will be resolved the same nonetheless
  let(:url) { ActiveRecord::Base.connection_config }
  let(:logger) do
    described_class.new(url, 'test_sql_table_logger')
  end

  before do
    logger.reset!
  end

  it 'logs lines at proper severity' do
    logger << 'test line'
    logger.info 'test info line'
    logger.warn 'test warn line'
    logger.error 'test error line'

    result = logger.lines
    expect(result).to include(hash_including('level' => 'ANY', 'body' => 'test line'))
    expect(result).to include(hash_including('level' => 'INFO', 'body' => 'test info line'))
    expect(result).to include(hash_including('level' => 'WARN', 'body' => 'test warn line'))
    expect(result).to include(hash_including('level' => 'ERROR', 'body' => 'test error line'))
  end

  it 'tees logs using ActiveSupport::Logger.broadcast' do
    # simulate the Rails logger
    fake_rails_output = StringIO.new
    fake_rails_logger = ActiveSupport::Logger.new(fake_rails_output)

    fake_rails_logger.extend(ActiveSupport::Logger.broadcast(logger))
    fake_rails_logger.info 'testing logger'

    expect(fake_rails_output.string).to include('testing logger')
    expect(logger.lines).to include(hash_including('level' => 'INFO', 'body' => 'testing logger'))
  end

  describe '#capture_rails_logger' do
    it 'captures output to Rails.logger in block' do
      logger.capture_rails_logger do
        Rails.logger.info 'Rails.logger info line'
      end

      expect(logger.lines).to include(hash_including('level' => 'INFO', 'body' => 'Rails.logger info line'))
    end

    it 'does not keep capturing after block' do
      logger.capture_rails_logger do
        # do nothing
      end

      log_line = 'Rails.logger after line'
      Rails.logger.info log_line
      expect(logger.lines).not_to include(hash_including('level' => 'INFO', 'body' => log_line))
    end
  end
end
