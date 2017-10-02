# frozen_string_literal: true

require 'rails_helper'

describe RightsFlow do
  let(:pages) { RightsFlow::PAGES }

  describe '#persist!' do
    let(:chosen_rights) do
      {
        'flag_b' => '1',
        'flag_i' => '1',
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

    context 'when the cookie contains a removed field' do
      before do
        allow_any_instance_of(RightsFlow)
          .to(receive(:flow_attributes))
          .and_wrap_original do |method, *args|
            method.call(*args).merge(previous_field_name: 'previous-field-value')
          end

        # temporarily add a new field
        @flow_cookie = RightsFlow.new(**random_field_values).to_cookie
      end

      it 'serializes/unserializes correctly' do
        expect(RightsFlow.from_cookie(@flow_cookie)).not_to be_nil
      end
    end
  end

  describe '#previous_step' do
    let(:start_page) { 2 }
    let(:flow) { RightsFlow.new(current_page: pages[start_page]) }

    it 'returns the right value' do
      expect(flow.previous_step).to eq(pages[start_page - 1])
    end

    context 'for the first page of the flow' do
      let(:start_page) { 0 }

      it 'returns nil' do
        expect(flow.previous_step).to be_nil
      end
    end
  end

  describe '#next_step' do
    let(:flow) { RightsFlow.new(current_page: pages[0]) }

    it 'returns the right value' do
      expect(flow.next_step).to eq(pages[1])
    end
  end
end
