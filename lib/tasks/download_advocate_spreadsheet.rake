# frozen_string_literal: true

namespace :casecompanion do
  desc 'Update the config/advocates.csv file'
  task download_advocate_spreadsheet: :environment do
    puts "Downloading #{AdvocateList::ADVOCATE_CSV_URL}..."
    puts "  to #{AdvocateList::ADVOCATE_CSV_PATH}"

    File.open(AdvocateList::ADVOCATE_CSV_PATH, 'w') do |f|
      body = Net::HTTP.get(URI(AdvocateList::ADVOCATE_CSV_URL))
      f.puts body
    end
  end
end
