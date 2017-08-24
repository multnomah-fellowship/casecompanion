# frozen_string_literal: true

require 'rails_helper'

EXAMPLE_CSV = <<~CSV
  CRIMES ID,Last Name,First Name,Email,Phone 1,Phone 2
  DOONERT,DOONER,Tom,tom@example.com,(503) 555-1234,
  SOMEONEELSE,,,,,
CSV

RSpec.describe AdvocateList do
  before do
    allow(described_class)
      .to receive(:read_csv)
      .and_return(EXAMPLE_CSV)
  end

  describe '.name_and_emails' do
    subject { described_class.name_and_emails }

    it 'translates the CSV into a list properly' do
      expect(subject)
        .to eq([['Tom Dooner', 'tom@example.com']])
    end
  end

  describe '.advocate_info_by_email' do
    subject { described_class.advocate_info_by_email('tom@example.com') }

    it 'returns the correct advocate info' do
      expect(subject)
        .to include(
          name: 'Tom Dooner',
          first_name: 'Tom',
          email: 'tom@example.com',
          phone: '(503) 555-1234',
        )
    end
  end
end
