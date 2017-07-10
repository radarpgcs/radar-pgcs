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

  test "should get employee's stars dashboard" do
    employee = Employee.find_by registry: 1
    proms = employee.promotions.count { |p| p.type == 'PM' }

    found = stars(employee).scan /("Star")/
    assert found
    assert_equal proms, found.size
  end

  test "should get employee's promotion dashboard" do
    employee = Employee.find_by registry: 2
    proms = { pm: 0, pts: 0 }

    employee.promotions.each do |p|
      next if p.year < employee.hiring_date.year

      if p.type == 'PM'
        proms[:pm] += 1
      elsif p.type == 'PTS'
        proms[:pts] += 1
      end
    end

    board = promotions_board(employee)
    found = board.scan(%r(/images/thumbs-down.png)).size
    assert_equal proms[:pts], found

    found = board.scan(%r(/images/thumbs-up.png)).size
    assert_equal proms[:pm], found
  end

  test 'should get payment reference' do
    expected = '07/2017'
    actual = payment_reference Payment.new(year: 2017, month: 7)

    assert_equal expected, actual
  end
end