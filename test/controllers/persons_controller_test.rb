require "test_helper"

class PersonsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get persons_index_url
    assert_response :success
  end
end
