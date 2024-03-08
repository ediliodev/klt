require 'test_helper'

class SinglepostransaccionestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @singlepostransaccionest = singlepostransaccionests(:one)
  end

  test "should get index" do
    get singlepostransaccionests_url
    assert_response :success
  end

  test "should get new" do
    get new_singlepostransaccionest_url
    assert_response :success
  end

  test "should create singlepostransaccionest" do
    assert_difference('Singlepostransaccionest.count') do
      post singlepostransaccionests_url, params: { singlepostransaccionest: { cashout: @singlepostransaccionest.cashout, creditin: @singlepostransaccionest.creditin } }
    end

    assert_redirected_to singlepostransaccionest_url(Singlepostransaccionest.last)
  end

  test "should show singlepostransaccionest" do
    get singlepostransaccionest_url(@singlepostransaccionest)
    assert_response :success
  end

  test "should get edit" do
    get edit_singlepostransaccionest_url(@singlepostransaccionest)
    assert_response :success
  end

  test "should update singlepostransaccionest" do
    patch singlepostransaccionest_url(@singlepostransaccionest), params: { singlepostransaccionest: { cashout: @singlepostransaccionest.cashout, creditin: @singlepostransaccionest.creditin } }
    assert_redirected_to singlepostransaccionest_url(@singlepostransaccionest)
  end

  test "should destroy singlepostransaccionest" do
    assert_difference('Singlepostransaccionest.count', -1) do
      delete singlepostransaccionest_url(@singlepostransaccionest)
    end

    assert_redirected_to singlepostransaccionests_url
  end
end
