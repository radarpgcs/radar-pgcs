require 'test_helper'

class PromotionsControllerTest < ActionController::TestCase
  setup do
    session[:user_so] = User.first
  end

  test 'should not get promotions index page if not authenticated' do
    session[:user_so] = nil

    get :index
    assert_response :success
    assert_template 'login'
  end

  test 'should get promotions index page' do
  	get :index
    assert_response :success
    assert_template 'promotions/index'
  end

  test 'should get finding promotions action' do
    get :find, params: { type: 'pm', staff: 'internal', year: Time.now.year }
    assert_redirected_to list_promotions_path(type: 'merito', staff: 'interno', year: Time.now.year)
  end

  test 'should get listing promotions page' do
    get :list, params: { type: 'merito', staff: 'interno', year: Time.now.year }
    assert_response :success
  end
end