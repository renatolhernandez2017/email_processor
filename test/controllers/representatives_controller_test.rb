require "test_helper"

class RepresentativesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get representatives_index_url
    assert_response :success
  end

  test "should get show" do
    get representatives_show_url
    assert_response :success
  end
end
