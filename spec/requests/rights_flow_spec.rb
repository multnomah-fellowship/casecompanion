require 'rails_helper'

RSpec.describe 'Rights selection flow' do
  it 'maintains the state across the entire session' do
    get '/rights'
    follow_redirect!
    expect(response.body).to include('to assert and enforce my rights')

    post '/rights/who_assert', params: { rights_flow: { 'flag_a_assert_dda' => '1' } }
    follow_redirect!
    expect(response.body).to include('critical stage')

    post '/rights/to_notification', params: { rights_flow: { 'flag_b_critical_stage' => '1' } }
    follow_redirect!
    expect(response.body).to include('restitution')

    post '/rights/to_financial_assistance', params: { rights_flow: { 'flag_k_restitution' => '1' } }
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
        'case_number' => '17CR1234'
      }
    }
    follow_redirect!
    expect(response.body).to include('all set')

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
  end

  it 'allows hitting back and saving an updated version' do
    get '/rights'
    follow_redirect!

    post '/rights/who_assert', params: { rights_flow: { 'flag_a_assert_dda' => '1' } }
    follow_redirect!

    post '/rights/to_notification', params: { rights_flow: { 'flag_b_critical_stage' => '1' } }
    follow_redirect!

    post '/rights/to_financial_assistance', params: { rights_flow: { 'flag_k_restitution' => '1' } }
    follow_redirect!

    post '/rights/in_special_cases'
    follow_redirect!

    post '/rights/create_account', params: {
      rights_flow: {
        'first_name' => 'Tom',
        'last_name' => 'Example',
        'email' => 'tom@example.com',
        'phone_number' => '330 555 1234',
        'case_number' => '17CR1234'
      }
    }
    follow_redirect!
    expect(response.body).to include('all set')

    post '/rights/create_account', params: {
      rights_flow: {
        'first_name' => 'Thomas',
        'last_name' => 'Example',
        'email' => 'Thomas@example.com',
        'phone_number' => '330 123 1234',
        'case_number' => '18CR1234'
      }
    }
    follow_redirect!
    expect(response.body).to include('Changes saved')

    subscription = CourtCaseSubscription.find_by(
      case_number: '18CR1234',
      email: 'Thomas@example.com',
    )
    expect(subscription).to be_present
    expect(subscription.phone_number).to eq('330 123 1234')
  end
end
