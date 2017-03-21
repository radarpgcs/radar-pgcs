require 'test_helper'

class EmployeesControllerTest < ActionController::TestCase
  setup do
    session[:user_so] = User.first
  end

  test 'should get showing employee page' do
  	get :show, params: { registry: Employee.first.registry }
    assert_response :success
    assert_template 'employees/show'
  end
end