require 'test_helper'

class FondotsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @fondot = fondots(:one)
  end

  test "should get index" do
    get fondots_url
    assert_response :success
  end

  test "should get new" do
    get new_fondot_url
    assert_response :success
  end

  test "should create fondot" do
    assert_difference('Fondot.count') do
      post fondots_url, params: { fondot: { cantidad: @fondot.cantidad } }
    end

    assert_redirected_to fondot_url(Fondot.last)
  end

  test "should show fondot" do
    get fondot_url(@fondot)
    assert_response :success
  end

  test "should get edit" do
    get edit_fondot_url(@fondot)
    assert_response :success
  end

  test "should update fondot" do
    patch fondot_url(@fondot), params: { fondot: { cantidad: @fondot.cantidad } }
    assert_redirected_to fondot_url(@fondot)
  end

  test "should destroy fondot" do
    assert_difference('Fondot.count', -1) do
      delete fondot_url(@fondot)
    end

    assert_redirected_to fondots_url
  end
end
