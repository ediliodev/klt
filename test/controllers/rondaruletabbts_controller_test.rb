require 'test_helper'

class RondaruletabbtsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @rondaruletabbt = rondaruletabbts(:one)
  end

  test "should get index" do
    get rondaruletabbts_url
    assert_response :success
  end

  test "should get new" do
    get new_rondaruletabbt_url
    assert_response :success
  end

  test "should create rondaruletabbt" do
    assert_difference('Rondaruletabbt.count') do
      post rondaruletabbts_url, params: { rondaruletabbt: { credit: @rondaruletabbt.credit, jugadas: @rondaruletabbt.jugadas, jugador: @rondaruletabbt.jugador, status: @rondaruletabbt.status, totalbet: @rondaruletabbt.totalbet, win: @rondaruletabbt.win, winnernumberspin: @rondaruletabbt.winnernumberspin } }
    end

    assert_redirected_to rondaruletabbt_url(Rondaruletabbt.last)
  end

  test "should show rondaruletabbt" do
    get rondaruletabbt_url(@rondaruletabbt)
    assert_response :success
  end

  test "should get edit" do
    get edit_rondaruletabbt_url(@rondaruletabbt)
    assert_response :success
  end

  test "should update rondaruletabbt" do
    patch rondaruletabbt_url(@rondaruletabbt), params: { rondaruletabbt: { credit: @rondaruletabbt.credit, jugadas: @rondaruletabbt.jugadas, jugador: @rondaruletabbt.jugador, status: @rondaruletabbt.status, totalbet: @rondaruletabbt.totalbet, win: @rondaruletabbt.win, winnernumberspin: @rondaruletabbt.winnernumberspin } }
    assert_redirected_to rondaruletabbt_url(@rondaruletabbt)
  end

  test "should destroy rondaruletabbt" do
    assert_difference('Rondaruletabbt.count', -1) do
      delete rondaruletabbt_url(@rondaruletabbt)
    end

    assert_redirected_to rondaruletabbts_url
  end
end
