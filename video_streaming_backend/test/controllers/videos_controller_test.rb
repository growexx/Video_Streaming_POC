require "test_helper"

class VideosControllerTest < ActionDispatch::IntegrationTest
  test "should get stream" do
    get videos_stream_url
    assert_response :success
  end
end
