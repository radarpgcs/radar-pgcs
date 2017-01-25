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

  test 'should not sign in' do
    post :sign_in, params: { identity: '00000000000', password: '123' }
    assert_template 'login', layout: nil
    assert_equal I18n.translate('login.authentication_failed.message'), flash[:danger]
  end

  test 'should sign in' do
    user = User.all.first
    post :sign_in, params: { identity: user.registry, password: user.password }
    
    assert_not flash[:danger]
    assert_response 302
    assert_redirected_to home_path
  end
end