class EmployeesHelperTest < ActionView::TestCase
  include EmployeesHelper

  test 'should get a eight digits number' do
    employee = Employee.find_by registry: 1
    expected = '00000001'
    
    assert_equal expected, format_registry(employee)

    employee = Employee.find_by registry: 13
    expected = '00000013'
    
    assert_equal expected, format_registry(employee)
  end

  test 'should get the regional name given an employee' do
    employee = Employee.find_by registry: 1
    expected = 'Belo Horizonte'

    assert_equal expected, format_regional(employee)

    employee = Employee.find_by registry: 2
    expected = 'São Paulo'

    assert_equal expected, format_regional(employee)
    employee = Employee.find_by registry: 3
    expected = 'Curitiba'

    assert_equal expected, format_regional(employee)
  end

  test "should get employee'stars dashboard" do
    employee = Employee.find_by registry: 1
    proms = employee.promotions.count { |p| p.type == 'PM' }

    found = stars(employee).scan /("Star")/
    assert found
    assert_equal proms, found.size
  end
end