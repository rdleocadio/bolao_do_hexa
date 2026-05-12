require "test_helper"

class Admin::GroupStandingOverridesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_group_standing_overrides_index_url
    assert_response :success
  end

  test "should get edit" do
    get admin_group_standing_overrides_edit_url
    assert_response :success
  end

  test "should get update" do
    get admin_group_standing_overrides_update_url
    assert_response :success
  end
end
