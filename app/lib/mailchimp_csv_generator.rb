# frozen_string_literal: true

class MailchimpCsvGenerator
  VRN_RECEIPT_QUERY_FILE = 'deploy/crimes-etl/queries/q-dump-processed-csv.sql'
  DCJ_HANDOFF_QUERY_FILE = 'deploy/crimes-etl/queries/q-dump-dcj-csv.sql'

  def initialize(local_crimes:, logger: Logger.new($stderr))
    @logger = logger
    @local_crimes = local_crimes
  end

  # @param [IO] out_io Where the CSV lines will be written.
  def generate_vrn_receipt_csv(out_io)
    @logger.info 'Generating VRN receipt CSV...'

    count = 0
    query = File.read(Rails.root.join(VRN_RECEIPT_QUERY_FILE))
    @local_crimes.export_query_as_csv(query).each do |row|
      count += 1
      out_io << row
    end

    @logger.info "  #{count} rows"
  end

  def generate_dcj_handoff_csv(out_io)
    @logger.info 'Generating DCJ handoff CSV...'

    count = 0
    query = File.read(Rails.root.join(DCJ_HANDOFF_QUERY_FILE))
    @local_crimes.export_query_as_csv(query).each do |row|
      count += 1
      out_io << row
    end

    @logger.info "  #{count} rows"
  end
end
