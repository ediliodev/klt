require 'test_helper'

class ContribuyentetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contribuyentet = contribuyentets(:one)
  end

  test "should get index" do
    get contribuyentets_url
    assert_response :success
  end

  test "should get new" do
    get new_contribuyentet_url
    assert_response :success
  end

  test "should create contribuyentet" do
    assert_difference('Contribuyentet.count') do
      post contribuyentets_url, params: { contribuyentet: { aportemega: @contribuyentet.aportemega, consorcio: @contribuyentet.consorcio, countermeternew: @contribuyentet.countermeternew, countermeterold: @contribuyentet.countermeterold, localidad: @contribuyentet.localidad, serialmq: @contribuyentet.serialmq, siglas: @contribuyentet.siglas, sucursal: @contribuyentet.sucursal } }
    end

    assert_redirected_to contribuyentet_url(Contribuyentet.last)
  end

  test "should show contribuyentet" do
    get contribuyentet_url(@contribuyentet)
    assert_response :success
  end

  test "should get edit" do
    get edit_contribuyentet_url(@contribuyentet)
    assert_response :success
  end

  test "should update contribuyentet" do
    patch contribuyentet_url(@contribuyentet), params: { contribuyentet: { aportemega: @contribuyentet.aportemega, consorcio: @contribuyentet.consorcio, countermeternew: @contribuyentet.countermeternew, countermeterold: @contribuyentet.countermeterold, localidad: @contribuyentet.localidad, serialmq: @contribuyentet.serialmq, siglas: @contribuyentet.siglas, sucursal: @contribuyentet.sucursal } }
    assert_redirected_to contribuyentet_url(@contribuyentet)
  end

  test "should destroy contribuyentet" do
    assert_difference('Contribuyentet.count', -1) do
      delete contribuyentet_url(@contribuyentet)
    end

    assert_redirected_to contribuyentets_url
  end
end
