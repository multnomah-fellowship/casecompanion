# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe 'Rights selection flow' do
  include_context 'with fake advocate'

  let(:params_notification) { { rights_flow: { 'flag_b' => '1' } } }
  let(:params_financial) { { rights_flow: { 'flag_k' => '1' } } }
  let(:params_special) { { rights_flow: {} } }
  let(:params_create_account) do
    {
      rights_flow: {
        'first_name' => 'Tom',
        'last_name' => 'Example',
        'email' => 'tom@example.com',
        'phone_number' => '330 555 1234',
        'case_number' => '1000000',
        'advocate_email' => FAKE_ADVOCATE_EMAIL,
        'dda_email' => 'tom+dda@example.com',
      },
    }
  end
  let(:params_confirm) do
    {
      rights_flow: {
        'electronic_signature_checked' => '1',
        # assert that it accepts a slightly messy signature, as we have seen
        # iPads want to type:
        'electronic_signature_name' => 'Tom example ',
      },
    }
  end

  it 'maintains the state across the entire session' do
    get '/rights'
    follow_redirect!
    expect(response.body).to include(I18n.t('rights_flow.new_header_html'))

    post '/rights/who_assert', params: {}
    follow_redirect!
    expect(response.body).to include('critical stage')

    post '/rights/to_notification', params: params_notification
    follow_redirect!
    expect(response.body).to include('restitution')

    post '/rights/to_financial_assistance', params: params_financial
    follow_redirect!
    expect(response.body).to include('sex offense proceedings')

    post '/rights/in_special_cases', params: params_special
    follow_redirect!
    expect(response.body).to include('How can we reach you?')

    post '/rights/create_account', params: params_create_account
    follow_redirect!
    expect(response.body).to include(I18n.t('rights_flow.confirmation.header'))

    # Check that it confirms the correct rights
    expect(response.body)
      .to include(I18n.t('rights.flag_b'))
    expect(response.body)
      .to include(I18n.t('rights.flag_k'))
    expect(response.body)
      .not_to include(I18n.t('rights.flag_c'))

    post '/rights/confirmation', params: params_confirm
    follow_redirect!

    # The latest subscription should have flags A, B, K...
    last_subscription = CourtCaseSubscription.last
    expect(last_subscription.rights_hash)
      .to include('B-Notified in advance of Critical Stage Proceedings' => true)
    expect(last_subscription.rights_hash)
      .to include('K-Right to Restitution' => true)

    # ...but not any other flags
    expect(last_subscription.rights_hash)
      .to include('A-DDA to assert and enforce Victim Rights' => false)
    expect(last_subscription.rights_hash)
      .to include('C-Talk with DDA before a Plea Agreement' => false)
  end

  it 'clears the session after ending the flow' do
    get '/rights'
    follow_redirect!

    post '/rights/who_assert', params: {}
    follow_redirect!

    post '/rights/to_notification', params: params_notification
    follow_redirect!

    post '/rights/to_financial_assistance', params: params_financial
    follow_redirect!

    post '/rights/in_special_cases', params: params_special
    follow_redirect!

    post '/rights/create_account', params: params_create_account
    follow_redirect!

    post '/rights/confirmation', params: params_confirm
    follow_redirect!
    expect(response.body).to include(I18n.t('rights_flow.done.focus_header'))

    # simulate clicking the browser back button
    get '/rights/create_account'
    expect(response).to redirect_to(right_path(RightsFlow.first_step))
  end

  it 'redirects when you try to go to a future page' do
    # first fill out a few pages
    get '/rights'
    follow_redirect!
    post '/rights/who_assert', params: {}
    follow_redirect!
    post '/rights/to_notification', params: params_notification
    follow_redirect!
    post '/rights/to_financial_assistance', params: params_financial
    follow_redirect!

    # then try to skip ahead
    get '/rights/confirmation'

    # verify that the skip was forbidden
    expect(response).to redirect_to('/rights/in_special_cases')
  end

  it 'redirects you back to the start when going to and end page' do
    get '/rights/confirmation'
    expect(response).to redirect_to('/rights/who_assert')
  end

  describe 'the create_account flow step' do
    before do
      get '/rights'
      follow_redirect!
      post '/rights/who_assert', params: {}
      follow_redirect!
      post '/rights/to_notification', params: params_notification
      follow_redirect!
      post '/rights/to_financial_assistance', params: params_financial
      follow_redirect!
      post '/rights/in_special_cases', params: params_special
      follow_redirect!
    end

    subject do
      post '/rights/create_account', params: params_create_account
      follow_redirect!
    end

    context 'with valid account params' do
      it 'confirms the correct account details' do
        subject
        expect(response.body).to include('Tom Example')
        expect(response.body).to include('tom@example.com')
        expect(response.body).to include('(330) 555-1234')
        expect(response.body).to include('1000000')
      end

      it 'persists the account details' do
        subject
        post '/rights/confirmation', params: params_confirm
        follow_redirect!

        last_subscription = CourtCaseSubscription.last
        expect(last_subscription.email)
          .to eq('tom@example.com')
        expect(last_subscription.advocate_email)
          .to eq(FAKE_ADVOCATE_EMAIL)
        expect(last_subscription.dda_email)
          .to eq('tom+dda@example.com')
      end
    end

    context 'without a phone number or email' do
      let(:params_create_account) do
        super().tap do |params|
          params[:rights_flow].merge!(
            'phone_number' => '',
            'email' => '',
          )
        end
      end

      it 'persists the account details' do
        subject
        post '/rights/confirmation', params: params_confirm
        follow_redirect!

        last_subscription = CourtCaseSubscription.last
        expect(last_subscription.email).to be_blank
        expect(last_subscription.phone_number).to be_blank
      end
    end
  end
end
