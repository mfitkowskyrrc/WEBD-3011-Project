require "test_helper"

class CartsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get carts_show_url
    assert_response :success
  end

  test "should get update" do
    get carts_update_url
    assert_response :success
  end

  test "should get add_product" do
    get carts_add_product_url
    assert_response :success
  end
end
