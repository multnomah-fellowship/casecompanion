# frozen_string_literal: true

namespace :mailchimp_csvs do
  desc 'generate DCJ and VRN mailchimp CSVs'
  task generate: :environment do
    logger = Rails.env.development? ? Logger.new($stderr) : Rails.logger
    output_path = ENV['CSV_OUTPUT_PATH'] || Rails.root.join('tmp')

    csv_generator = MailchimpCsvGenerator.new(
      logger: logger,
      local_crimes: LocalCrimesInPostgres.new,
    )

    # VRN receipt/confirmation email
    vrn_receipt_path = File.join(output_path, "output-victims-#{Date.today}.csv")
    File.open(vrn_receipt_path, 'w') do |f|
      csv_generator.generate_vrn_receipt_csv(f)
    end
    logger.info "  Created #{vrn_receipt_path}"

    # DCJ handoff
    dcj_handoff_path = File.join(output_path, "output-dcj-#{Date.today}.csv")
    File.open(dcj_handoff_path, 'w') do |f|
      csv_generator.generate_dcj_handoff_csv(f)
    end
    logger.info "  Created #{dcj_handoff_path}"
  end
end
