require 'test_helper'

class EmployeesControllerTest < ActionController::TestCase
  setup do
    session[:user_so] = User.first
  end

  test 'should get showing employee page' do
  	get :show, params: { registry: Employee.first.registry }
    assert_response :success

    assert_not_nil assigns(:employee)
    assert_template 'employees/show'
  end

  test 'should get payment history page' do
    get :payment_history, params: { registry: Employee.first.registry }
    assert_response :success

    assert_not_nil assigns(:employee)
    assert_not_nil assigns(:payments)
    assert_template 'employees/payment_history'
  end
end