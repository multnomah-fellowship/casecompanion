# frozen_string_literal: true

RSpec.shared_context 'as an admin' do
  let(:admin_user) do
    User.create(email: 'tom@example.com', password: 'password123', is_admin: true)
  end

  before do
    request.session[:user_id] = admin_user.id
  end
end
