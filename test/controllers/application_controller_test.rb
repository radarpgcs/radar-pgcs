require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase

  setup do
    registry = 12345678
    user = User.where(registry: registry).first

    User.create!(registry: registry, password: '12345',
      status: 'ACTIVE',roles: %w(MEMBER)) unless user

    employee = Employee.where(registry: registry).first

    Employee.create!(registry: registry, name: 'Johann Wolfgang von Goethe',
      active: true) unless employee
  end

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
    user = User.find_by registry: 12345678
    post :sign_in, params: { identity: user.registry, password: '12345' }
    
    assert_not flash[:danger]
    assert_response 302
    assert_redirected_to home_path
  end

  test 'should sign user out' do
    delete :sign_out, session: { registry: '00000000000' }
    assert_response 302
    assert_redirected_to home_path
  end
end