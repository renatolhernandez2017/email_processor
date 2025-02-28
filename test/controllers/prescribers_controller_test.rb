require "test_helper"

class PrescribersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get prescribers_index_url
    assert_response :success
  end
end
