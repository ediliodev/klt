require 'test_helper'

class RondatsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @rondat = rondats(:one)
  end

  test "should get index" do
    get rondats_url
    assert_response :success
  end

  test "should get new" do
    get new_rondat_url
    assert_response :success
  end

  test "should create rondat" do
    assert_difference('Rondat.count') do
      post rondats_url, params: { rondat: { cartucho: @rondat.cartucho, credito: @rondat.credito, jugador: @rondat.jugador, posiciondisparo: @rondat.posiciondisparo, resultado: @rondat.resultado } }
    end

    assert_redirected_to rondat_url(Rondat.last)
  end

  test "should show rondat" do
    get rondat_url(@rondat)
    assert_response :success
  end

  test "should get edit" do
    get edit_rondat_url(@rondat)
    assert_response :success
  end

  test "should update rondat" do
    patch rondat_url(@rondat), params: { rondat: { cartucho: @rondat.cartucho, credito: @rondat.credito, jugador: @rondat.jugador, posiciondisparo: @rondat.posiciondisparo, resultado: @rondat.resultado } }
    assert_redirected_to rondat_url(@rondat)
  end

  test "should destroy rondat" do
    assert_difference('Rondat.count', -1) do
      delete rondat_url(@rondat)
    end

    assert_redirected_to rondats_url
  end
end
