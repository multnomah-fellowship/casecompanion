require 'rails_helper'

RSpec.describe 'Rights selection flow' do
  it 'maintains the state across the entire session' do
    get '/rights'
    follow_redirect!
    expect(response.body).to include('Assert')

    post '/rights/who_assert', params: { rights_flow: { 'flag_a_assert_dda' => '1' } }
    follow_redirect!
    expect(response.body).to include('Critical Stage')

    post '/rights/to_notification', params: { rights_flow: { 'flag_b_critical_stage' => '1' } }
    follow_redirect!
    expect(response.body).to include('Restitution')

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

    # TODO: add assertions about the user creation
  end
end