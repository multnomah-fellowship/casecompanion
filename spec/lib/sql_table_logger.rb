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
end
