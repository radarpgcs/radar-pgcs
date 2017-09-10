require 'test_helper'

class GfeTablesControllerTest < ActionController::TestCase
  setup do
    session[:user_so] = User.first
  end

  test 'should not get gfe table index page if not authenticated' do
    session[:user_so] = nil

    get :index
    assert_response :success
    assert_template 'login'
  end

  test 'should get gfe table index page' do
  	get :index
    assert_response :success
    assert_template 'gfe_tables/index'
  end
end