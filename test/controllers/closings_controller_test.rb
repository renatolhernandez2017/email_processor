require "test_helper"

class ClosingsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get closings_index_url
    assert_response :success
  end

  test "should get show" do
    get closings_show_url
    assert_response :success
  end

  test "should get new" do
    get closings_new_url
    assert_response :success
  end
end
