require 'rails_helper'

describe RightsController, type: :controller do
  render_views

  describe '#index' do
    it 'redirects to the first right' do
      get :index
      expect(response)
        .to redirect_to(right_path(RightsFlow::PAGES[0]))
    end
  end

  describe '#show' do
    RightsFlow::PAGES.each do |right_page|
      it "renders page '#{right_page}'" do
        get :show, params: { id: right_page }
        expect(response).to be_success
      end
    end
  end
end
