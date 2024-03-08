require 'test_helper'

class GanadoresmegajackpotsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ganadoresmegajackpot = ganadoresmegajackpots(:one)
  end

  test "should get index" do
    get ganadoresmegajackpots_url
    assert_response :success
  end

  test "should get new" do
    get new_ganadoresmegajackpot_url
    assert_response :success
  end

  test "should create ganadoresmegajackpot" do
    assert_difference('Ganadoresmegajackpot.count') do
      post ganadoresmegajackpots_url, params: { ganadoresmegajackpot: { cantidad: @ganadoresmegajackpot.cantidad, consorcio: @ganadoresmegajackpot.consorcio, fecha: @ganadoresmegajackpot.fecha, localidad: @ganadoresmegajackpot.localidad, montoxcontribuyente: @ganadoresmegajackpot.montoxcontribuyente, serialmq: @ganadoresmegajackpot.serialmq, sucursal: @ganadoresmegajackpot.sucursal } }
    end

    assert_redirected_to ganadoresmegajackpot_url(Ganadoresmegajackpot.last)
  end

  test "should show ganadoresmegajackpot" do
    get ganadoresmegajackpot_url(@ganadoresmegajackpot)
    assert_response :success
  end

  test "should get edit" do
    get edit_ganadoresmegajackpot_url(@ganadoresmegajackpot)
    assert_response :success
  end

  test "should update ganadoresmegajackpot" do
    patch ganadoresmegajackpot_url(@ganadoresmegajackpot), params: { ganadoresmegajackpot: { cantidad: @ganadoresmegajackpot.cantidad, consorcio: @ganadoresmegajackpot.consorcio, fecha: @ganadoresmegajackpot.fecha, localidad: @ganadoresmegajackpot.localidad, montoxcontribuyente: @ganadoresmegajackpot.montoxcontribuyente, serialmq: @ganadoresmegajackpot.serialmq, sucursal: @ganadoresmegajackpot.sucursal } }
    assert_redirected_to ganadoresmegajackpot_url(@ganadoresmegajackpot)
  end

  test "should destroy ganadoresmegajackpot" do
    assert_difference('Ganadoresmegajackpot.count', -1) do
      delete ganadoresmegajackpot_url(@ganadoresmegajackpot)
    end

    assert_redirected_to ganadoresmegajackpots_url
  end
end
