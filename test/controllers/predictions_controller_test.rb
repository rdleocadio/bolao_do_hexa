require "test_helper"

class PredictionsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get predictions_create_url
    assert_response :success
  end

  test "should get update" do
    get predictions_update_url
    assert_response :success
  end
end
