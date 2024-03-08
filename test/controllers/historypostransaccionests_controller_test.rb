require 'test_helper'

class HistorypostransaccionestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @historypostransaccionest = historypostransaccionests(:one)
  end

  test "should get index" do
    get historypostransaccionests_url
    assert_response :success
  end

  test "should get new" do
    get new_historypostransaccionest_url
    assert_response :success
  end

  test "should create historypostransaccionest" do
    assert_difference('Historypostransaccionest.count') do
      post historypostransaccionests_url, params: { historypostransaccionest: { cashout: @historypostransaccionest.cashout, creditin: @historypostransaccionest.creditin } }
    end

    assert_redirected_to historypostransaccionest_url(Historypostransaccionest.last)
  end

  test "should show historypostransaccionest" do
    get historypostransaccionest_url(@historypostransaccionest)
    assert_response :success
  end

  test "should get edit" do
    get edit_historypostransaccionest_url(@historypostransaccionest)
    assert_response :success
  end

  test "should update historypostransaccionest" do
    patch historypostransaccionest_url(@historypostransaccionest), params: { historypostransaccionest: { cashout: @historypostransaccionest.cashout, creditin: @historypostransaccionest.creditin } }
    assert_redirected_to historypostransaccionest_url(@historypostransaccionest)
  end

  test "should destroy historypostransaccionest" do
    assert_difference('Historypostransaccionest.count', -1) do
      delete historypostransaccionest_url(@historypostransaccionest)
    end

    assert_redirected_to historypostransaccionests_url
  end
end
