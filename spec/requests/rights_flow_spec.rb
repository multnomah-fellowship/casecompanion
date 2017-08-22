# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Rights selection flow' do
  it 'maintains the state across the entire session' do
    get '/rights'
    follow_redirect!
    expect(response.body).to include('to assert and enforce my rights')

    post '/rights/who_assert', params: { rights_flow: { 'flag_a' => '1' } }
    follow_redirect!
    expect(response.body).to include('critical stage')

    post '/rights/to_notification', params: { rights_flow: { 'flag_b' => '1' } }
    follow_redirect!
    expect(response.body).to include('restitution')

    post '/rights/to_financial_assistance', params: { rights_flow: { 'flag_k' => '1' } }
    follow_redirect!
    expect(response.body).to include('sex offense proceedings')

    post '/rights/in_special_cases'
    follow_redirect!
    expect(response.body).to include('How can we reach you?')

    post '/rights/create_account', params: {
      rights_flow: {
        'first_name' => 'Tom',
        'last_name' => 'Example',
        'email' => 'tom@example.com',
        'phone_number' => '330 555 1234',
        'case_number' => '1000000',
        'advocate_email' => 'advocate@example.com',
      },
    }
    follow_redirect!
    expect(response.body).to include(I18n.t('rights_flow.confirmation.header'))

    # Check that it confirms the correct rights
    expect(response.body)
      .to include(I18n.t('rights.flag_a'))
    expect(response.body)
      .to include(I18n.t('rights.flag_b'))
    expect(response.body)
      .to include(I18n.t('rights.flag_k'))
    expect(response.body)
      .not_to include(I18n.t('rights.flag_c'))

    # Check that it confirms my contact info
    expect(response.body).to include('Tom Example')
    expect(response.body).to include('tom@example.com')
    expect(response.body).to include('(330) 555-1234')
    expect(response.body).to include('1000000')

    post '/rights/confirmation', params: {
      rights_flow: {
        'electronic_signature_checked' => '1',
        'electronic_signature_name' => 'Tom Example',
      },
    }
    follow_redirect!

    # The latest subscription should have flags A, B, K...
    last_subscription = CourtCaseSubscription.last
    expect(last_subscription.rights_hash)
      .to include('A-DDA to assert and enforce Victim Rights' => true)
    expect(last_subscription.rights_hash)
      .to include('B-Notified in advance of Critical Stage Proceedings' => true)
    expect(last_subscription.rights_hash)
      .to include('K-Right to Restitution' => true)

    # ...but not any other flags
    expect(last_subscription.rights_hash)
      .to include('C-Talk with DDA before a Plea Agreement' => false)

    expect(last_subscription.email)
      .to eq('tom@example.com')
    expect(last_subscription.advocate_email)
      .to eq('advocate@example.com')
  end

  it 'allows hitting back and saving an updated version' do
    get '/rights'
    follow_redirect!

    post '/rights/who_assert', params: { rights_flow: { 'flag_a' => '1' } }
    follow_redirect!

    post '/rights/to_notification', params: { rights_flow: { 'flag_b' => '1' } }
    follow_redirect!

    post '/rights/to_financial_assistance', params: { rights_flow: { 'flag_k' => '1' } }
    follow_redirect!

    post '/rights/in_special_cases'
    follow_redirect!

    post '/rights/create_account', params: {
      rights_flow: {
        'first_name' => 'Tom',
        'last_name' => 'Example',
        'email' => 'tom@example.com',
        'phone_number' => '330 555 1234',
        'case_number' => '1000000',
        'advocate_email' => 'advocate@example.com',
      },
    }
    follow_redirect!

    post '/rights/confirmation', params: {
      rights_flow: {
        'electronic_signature_checked' => '1',
        'electronic_signature_name' => 'Tom Example',
      },
    }
    follow_redirect!
    expect(response.body).to include(I18n.t('rights_flow.done.focus_header'))

    post '/rights/create_account', params: {
      rights_flow: {
        'first_name' => 'Thomas',
        'last_name' => 'Example',
        'email' => 'Thomas@example.com',
        'phone_number' => '330 123 1234',
        'case_number' => '1000001',
      },
    }
    follow_redirect!

    post '/rights/confirmation', params: {
      rights_flow: {
        'electronic_signature_checked' => '1',
        'electronic_signature_name' => 'Thomas Example',
      },
    }
    follow_redirect!
    expect(response.body).to include(I18n.t('rights_flow.done.focus_header_changed'))

    subscription = CourtCaseSubscription.find_by(
      case_number: '1000001',
      email: 'Thomas@example.com',
    )
    expect(subscription).to be_present
    expect(subscription.phone_number).to eq('330 123 1234')
    expect(subscription.first_name).to eq('Thomas')
  end
end
