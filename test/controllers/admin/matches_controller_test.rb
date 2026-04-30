require "test_helper"

class Admin::MatchesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_matches_index_url
    assert_response :success
  end

  test "should get edit" do
    get admin_matches_edit_url
    assert_response :success
  end
end
