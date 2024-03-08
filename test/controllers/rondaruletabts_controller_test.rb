require 'test_helper'

class RondaruletabtsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @rondaruletabt = rondaruletabts(:one)
  end

  test "should get index" do
    get rondaruletabts_url
    assert_response :success
  end

  test "should get new" do
    get new_rondaruletabt_url
    assert_response :success
  end

  test "should create rondaruletabt" do
    assert_difference('Rondaruletabt.count') do
      post rondaruletabts_url, params: { rondaruletabt: { credit: @rondaruletabt.credit, jugadas: @rondaruletabt.jugadas, jugador: @rondaruletabt.jugador, status: @rondaruletabt.status, totalbet: @rondaruletabt.totalbet, win: @rondaruletabt.win, winnernumberspin: @rondaruletabt.winnernumberspin } }
    end

    assert_redirected_to rondaruletabt_url(Rondaruletabt.last)
  end

  test "should show rondaruletabt" do
    get rondaruletabt_url(@rondaruletabt)
    assert_response :success
  end

  test "should get edit" do
    get edit_rondaruletabt_url(@rondaruletabt)
    assert_response :success
  end

  test "should update rondaruletabt" do
    patch rondaruletabt_url(@rondaruletabt), params: { rondaruletabt: { credit: @rondaruletabt.credit, jugadas: @rondaruletabt.jugadas, jugador: @rondaruletabt.jugador, status: @rondaruletabt.status, totalbet: @rondaruletabt.totalbet, win: @rondaruletabt.win, winnernumberspin: @rondaruletabt.winnernumberspin } }
    assert_redirected_to rondaruletabt_url(@rondaruletabt)
  end

  test "should destroy rondaruletabt" do
    assert_difference('Rondaruletabt.count', -1) do
      delete rondaruletabt_url(@rondaruletabt)
    end

    assert_redirected_to rondaruletabts_url
  end
end
