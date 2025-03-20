require "test_helper"

class CurrentAccountsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get current_accounts_index_url
    assert_response :success
  end
end
