class RightsController < ApplicationController
  RIGHTS_FLOW_PAGES = %w[
    who_assert
    to_notification
    to_financial_assistance
    in_special_cases
  ]


  def index
    redirect_to right_path(RIGHTS_FLOW_PAGES.first)
  end

  def show
  end
end
