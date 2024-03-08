require 'test_helper'

class JackpotsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @jackpot = jackpots(:one)
  end

  test "should get index" do
    get jackpots_url
    assert_response :success
  end

  test "should get new" do
    get new_jackpot_url
    assert_response :success
  end

  test "should create jackpot" do
    assert_difference('Jackpot.count') do
      post jackpots_url, params: { jackpot: { cantidad: @jackpot.cantidad, color: @jackpot.color, totalinnow: @jackpot.totalinnow, totalinold: @jackpot.totalinold, trigger: @jackpot.trigger } }
    end

    assert_redirected_to jackpot_url(Jackpot.last)
  end

  test "should show jackpot" do
    get jackpot_url(@jackpot)
    assert_response :success
  end

  test "should get edit" do
    get edit_jackpot_url(@jackpot)
    assert_response :success
  end

  test "should update jackpot" do
    patch jackpot_url(@jackpot), params: { jackpot: { cantidad: @jackpot.cantidad, color: @jackpot.color, totalinnow: @jackpot.totalinnow, totalinold: @jackpot.totalinold, trigger: @jackpot.trigger } }
    assert_redirected_to jackpot_url(@jackpot)
  end

  test "should destroy jackpot" do
    assert_difference('Jackpot.count', -1) do
      delete jackpot_url(@jackpot)
    end

    assert_redirected_to jackpots_url
  end
end
