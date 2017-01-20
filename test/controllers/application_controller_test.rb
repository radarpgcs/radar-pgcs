require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  
  test 'should get index page' do
    get :index
    assert_response :success
    assert_template 'index', layout: nil
  end

  test 'should get login' do
    get :login
    assert_response :success
    assert_template 'login', layout: nil
  end
end