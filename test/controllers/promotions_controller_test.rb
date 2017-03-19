require 'test_helper'

class PromotionsControllerTest < ActionController::TestCase
  test 'should not get promotions index page if not authenticated' do
    get :index
    assert_response :success
    assert_template 'login'
  end

  test 'should get promotions index page' do
  	session[:user_so] = User.first

    get :index
    assert_response :success
    assert_template 'promotions/index'
  end
end