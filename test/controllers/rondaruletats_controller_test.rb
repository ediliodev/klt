require 'test_helper'

class RondaruletatsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @rondaruletat = rondaruletats(:one)
  end

  test "should get index" do
    get rondaruletats_url
    assert_response :success
  end

  test "should get new" do
    get new_rondaruletat_url
    assert_response :success
  end

  test "should create rondaruletat" do
    assert_difference('Rondaruletat.count') do
      post rondaruletats_url, params: { rondaruletat: {  } }
    end

    assert_redirected_to rondaruletat_url(Rondaruletat.last)
  end

  test "should show rondaruletat" do
    get rondaruletat_url(@rondaruletat)
    assert_response :success
  end

  test "should get edit" do
    get edit_rondaruletat_url(@rondaruletat)
    assert_response :success
  end

  test "should update rondaruletat" do
    patch rondaruletat_url(@rondaruletat), params: { rondaruletat: {  } }
    assert_redirected_to rondaruletat_url(@rondaruletat)
  end

  test "should destroy rondaruletat" do
    assert_difference('Rondaruletat.count', -1) do
      delete rondaruletat_url(@rondaruletat)
    end

    assert_redirected_to rondaruletats_url
  end
end
