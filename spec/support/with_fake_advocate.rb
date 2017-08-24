# frozen_string_literal: false

# Create a fake advocate in the AdvocateList for purposes of testing

FAKE_ADVOCATE_EMAIL = 'advocate@example.com'.freeze

RSpec.shared_context 'with fake advocate' do
  before do
    allow(AdvocateList)
      .to receive(:all)
      .and_return([
        {
          'First Name' => 'Tom',
          'Last Name' => 'DOONER',
          'Email' => FAKE_ADVOCATE_EMAIL,
          'Phone 1' => '(503) 555-1234',
        },
      ])
  end
end
