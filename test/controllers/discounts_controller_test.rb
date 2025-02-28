require "test_helper"

class DiscountsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get discounts_index_url
    assert_response :success
  end
end
