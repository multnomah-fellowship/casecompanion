require 'rails_helper'

describe RightsFlow do
  let(:pages) { RightsFlow::PAGES }

  describe '#persist!' do
    let(:chosen_rights) do
      {
        'flag_b_critical_stage' => '1',
        'flag_i_no_media' => '1',
      }
    end

    context 'for a flow that has an existing user' do
      let(:flow) do
        RightsFlow.new(**chosen_rights.merge(court_case_subscription_id: 123))
      end

      it 'updates the court_case_subscription given'
    end

    context 'for a flow that is going to create a user' do
      let(:flow) do
        RightsFlow.new(**chosen_rights.merge(
          'first_name' => 'Tom',
          'last_name' => 'Dooner',
          'email' => 'tom@example.com',
          'phone_number' => '330 555 1234',
          'case_number' => '17CR1234'
        ))
      end

      it 'creates a court_case_subscription'
    end
  end

  describe '#to_cookie / #from_cookie' do
    let(:random_field_values) do
      Hash[RightsFlow::FIELDS.map { |f| [f.to_sym, Random.rand(1000).to_s] }]
    end

    let(:flow) { RightsFlow.new(**random_field_values) }

    it 'serializes/unserializes correctly' do
      expect(RightsFlow.from_cookie(flow.to_cookie))
        .to eq(flow)
    end
  end

  describe '#next_step' do
    let(:flow) { RightsFlow.new(current_page: pages[0]) }

    it 'returns the right value' do
      expect(flow.next_step).to eq(pages[1])
    end

    context 'when the next step is skipped' do
      before do
        allow(flow).to receive(:skip_step?).and_call_original
        allow(flow)
          .to receive(:skip_step?)
          .with(pages[1])
          .and_return(true)

      end

      it 'skips that step' do
        expect(flow.next_step).to eq(pages[2])
      end
    end
  end
end
