# frozen_string_literal: true

require 'csv'

# Class which encapsulates the logic of listing advocates
#
# For example:
#
#  AdvocateList.name_and_emails
#  => [["name 1", "email 1"], ...]
class AdvocateList
  ADVOCATE_CSV_URL = 'https://docs.google.com/spreadsheets/d/1kDpMM3Ls44NuPUkluSo6dUwMTseSGLS3K1GqteYxisY/pub?gid=0&single=true&output=csv'
  ADVOCATE_CSV_PATH = File.expand_path('../../../config/advocates.csv', __FILE__)

  class << self
    # The CSV can be downloaded with `bin/rails casecompanion:download_advocate_spreadsheet`
    # TODO: Download this list at deploy-time as well.
    def all
      @_list ||= begin
                  csv = CSV.parse(read_csv, headers: :first_row)
                  csv.find_all { |r| r['First Name'].present? }.map(&:to_h)
                end
    end

    def name_and_emails
      all
        .map { |r| [formatted_advocate_name(r), r['Email']] }
        .sort_by(&:first)
    end

    def advocate_info_by_email(email)
      row = all.detect { |r| r['Email'] == email }
      return unless row

      {
        name: formatted_advocate_name(row),
        first_name: row['First Name'],
        email: row['Email'],
        phone: row['Phone 1'],
      }
    end

    private

    def read_csv
      File.read(ADVOCATE_CSV_PATH).strip
    end

    def formatted_advocate_name(row)
      properly_capitalized_last = row['Last Name']
      properly_capitalized_last.capitalize! if properly_capitalized_last.match?(/^[A-Z\-]+$/)

      "#{row['First Name']} #{properly_capitalized_last}"
    end
  end
end
