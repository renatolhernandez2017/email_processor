require "test_helper"

class BranchesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get branches_index_url
    assert_response :success
  end
end
