require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase

  DEFAULT_USR_PWD = '12345'
  setup do
    registry = 12345678
    user = User.where(registry: registry).first

    User.create!(registry: registry, password: DEFAULT_USR_PWD,
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

  test 'should not sign in with invalid credential' do
    post :sign_in, params: { identity: '00000000000', password: '123' }
    assert_template 'login', layout: nil
    assert_equal I18n.translate('login.authentication_failed.message'), flash[:danger]
  end

  test 'should not sign blocked user in' do
    user = User.find_by registry: 12345678
    user.status = 'BLOCKED'
    user.password = DEFAULT_USR_PWD
    user.save

    post :sign_in, params: { identity: user.registry, password: DEFAULT_USR_PWD }
    assert_template 'login', layout: false

    expected_message = I18n.translate('sign_in.blocked_user', user: user.registry, note: user.status_note)
    assert_equal expected_message, flash[:danger]
  end

  test 'should redirect inactive user to activation page' do
    user = User.find_by registry: 12345678
    user.status = 'INACTIVE'
    user.password = DEFAULT_USR_PWD
    user.save

    post :sign_in, params: { identity: user.registry, password: DEFAULT_USR_PWD }
    assert_redirected_to activate_user_path(registry: user.registry)

    expected_message = I18n.translate('sign_in.inactive_user')
    assert_equal expected_message, flash[:warning]
  end

  test 'should sign in' do
    user = User.find_by registry: 12345678
    user.status = 'ACTIVE'
    user.password = DEFAULT_USR_PWD
    user.save

    post :sign_in, params: { identity: user.registry, password: DEFAULT_USR_PWD }
    
    assert_not flash[:danger]
    assert_response 302
    assert_redirected_to home_path
  end

  test 'should sign user out' do
    delete :sign_out, session: { registry: '00000000000' }
    assert_response 302
    assert_redirected_to home_path
  end

  test 'should get contact page' do
    get :contact
    assert_response :success
  end

  test 'should get news page' do
    get :news
    assert_response :success
  end

  test 'should get faq page' do
    get :faq
    assert_response :success
  end

  test 'should not get activation page when its status is not INACTIVE' do
    user = User.find_by registry: 12345678
    user.status = 'ACTIVE'
    user.password = DEFAULT_USR_PWD
    user.save

    get :activate_user, params: { registry: 12345678 }
    assert_response 302
    assert_redirected_to home_path
  end

  test 'should get user activation page' do
    user = User.find_by registry: 12345678
    user.status = 'INACTIVE'
    user.password = DEFAULT_USR_PWD
    user.save

    get :activate_user, params: { registry: 12345678 }
    assert_response :success
    assert_template 'activate_user', layout: 'public'
  end
end