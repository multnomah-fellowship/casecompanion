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

    subject { flow.persist! }

    context 'for a flow that has an existing user' do
      let(:user) { User.create(email: 'tom@example.com', password: 'foobar') }
      let(:court_case_subscription) do
        CourtCaseSubscription.create(user: user, case_number: '17CR1234')
      end

      let(:flow) do
        RightsFlow.new(
          **chosen_rights
            .symbolize_keys
            .merge(court_case_subscription_id: court_case_subscription.id),
        )
      end

      it 'updates the court_case_subscription given' do
        subject

        expect(court_case_subscription.rights_hash)
          .to include('A-DDA to assert and enforce Victim Rights' => false)
        expect(court_case_subscription.rights_hash)
          .to include('B-Notified in advance of Critical Stage Proceedings' => true)
        expect(court_case_subscription.rights_hash)
          .to include('I-No media coverage of Sex Offense Proceedings' => true)
      end
    end

    context 'for a flow that has user contact info' do
      let(:flow) do
        RightsFlow.new(**chosen_rights.merge(
          'first_name' => 'Tom',
          'last_name' => 'Dooner',
          'email' => 'tom@example.com',
          'phone_number' => '330 555 1234',
          'case_number' => '17CR1234',
        ).symbolize_keys)
      end

      it 'creates a court_case_subscription with the user information' do
        expect { subject }.to change { CourtCaseSubscription.count }.by(1)

        last_subscription = CourtCaseSubscription.last
        expect(last_subscription.email).to eq('tom@example.com')
        expect(last_subscription.phone_number).to eq('330 555 1234')
        expect(last_subscription.rights_hash)
          .to include('A-DDA to assert and enforce Victim Rights' => false)
        expect(last_subscription.rights_hash)
          .to include('B-Notified in advance of Critical Stage Proceedings' => true)
        expect(last_subscription.rights_hash)
          .to include('I-No media coverage of Sex Offense Proceedings' => true)
      end
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
