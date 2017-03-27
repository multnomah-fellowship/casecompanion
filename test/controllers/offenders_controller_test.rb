require 'test_helper'

class OffendersControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get offenders_show_url
    assert_response :success
  end

end
