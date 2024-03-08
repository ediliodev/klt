require 'test_helper'

class CashboxtsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cashboxt = cashboxts(:one)
  end

  test "should get index" do
    get cashboxts_url
    assert_response :success
  end

  test "should get new" do
    get new_cashboxt_url
    assert_response :success
  end

  test "should create cashboxt" do
    assert_difference('Cashboxt.count') do
      post cashboxts_url, params: { cashboxt: { cantidad: @cashboxt.cantidad } }
    end

    assert_redirected_to cashboxt_url(Cashboxt.last)
  end

  test "should show cashboxt" do
    get cashboxt_url(@cashboxt)
    assert_response :success
  end

  test "should get edit" do
    get edit_cashboxt_url(@cashboxt)
    assert_response :success
  end

  test "should update cashboxt" do
    patch cashboxt_url(@cashboxt), params: { cashboxt: { cantidad: @cashboxt.cantidad } }
    assert_redirected_to cashboxt_url(@cashboxt)
  end

  test "should destroy cashboxt" do
    assert_difference('Cashboxt.count', -1) do
      delete cashboxt_url(@cashboxt)
    end

    assert_redirected_to cashboxts_url
  end
end
