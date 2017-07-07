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

    post '/rights/create_account'
    follow_redirect!
    expect(response).to be_success

    # TODO: assert that the proper objects were created at the end of this.
  end
end
