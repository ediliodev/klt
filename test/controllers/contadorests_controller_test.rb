require 'test_helper'

class ContadorestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contadorest = contadorests(:one)
  end

  test "should get index" do
    get contadorests_url
    assert_response :success
  end

  test "should get new" do
    get new_contadorest_url
    assert_response :success
  end

  test "should create contadorest" do
    assert_difference('Contadorest.count') do
      post contadorests_url, params: { contadorest: { totalin: @contadorest.totalin, totalnet: @contadorest.totalnet, totalout: @contadorest.totalout } }
    end

    assert_redirected_to contadorest_url(Contadorest.last)
  end

  test "should show contadorest" do
    get contadorest_url(@contadorest)
    assert_response :success
  end

  test "should get edit" do
    get edit_contadorest_url(@contadorest)
    assert_response :success
  end

  test "should update contadorest" do
    patch contadorest_url(@contadorest), params: { contadorest: { totalin: @contadorest.totalin, totalnet: @contadorest.totalnet, totalout: @contadorest.totalout } }
    assert_redirected_to contadorest_url(@contadorest)
  end

  test "should destroy contadorest" do
    assert_difference('Contadorest.count', -1) do
      delete contadorest_url(@contadorest)
    end

    assert_redirected_to contadorests_url
  end
end
