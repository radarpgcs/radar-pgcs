require 'test_helper'

class EmployeeTest < ActiveSupport::TestCase
  test 'should not be equal' do
    employee = Employee.new registry: 12345

    e = nil
    assert_not employee == e

    e = Employee.new
    assert_not employee == e
  end

  test 'should be equal' do
    employee = Employee.new registry: 12345

    assert employee == employee
    e = employee.dup
    assert employee == e

    e = Employee.new registry: 12345
    assert employee == e
  end

  test 'should validate registry presence' do
    employee = Employee.new do |e|
      e.name = 'Goethe'
      e.active = true
    end

    assert employee.invalid?

    errors = employee.errors.messages
    assert_equal 1, errors[:registry].size
    assert_equal 'não pode ficar em branco', errors[:registry].first
  end

  test 'should validate name presence' do
    employee = Employee.new do |e|
      e.registry = '12345'
      e.active = true
    end

    assert employee.invalid?

    errors = employee.errors.messages
    assert_equal 2, errors[:name].size
    assert_equal 'não pode ficar em branco', errors[:name].first
  end

  test 'should validate name minimum size' do
  	minimum = 5
    employee = Employee.new do |e|
      e.registry = '12345'
      e.name = '*' * (minimum - 1)
      e.active = true
    end

    assert employee.invalid?

    errors = employee.errors.messages
    assert_equal 1, errors[:name].size
    assert_equal 'é muito curto (mínimo: 5 caracteres)', errors[:name].first
  end

  test 'should validate name maximum size' do
  	maximum = 80
    employee = Employee.new do |e|
      e.registry = '12345'
      e.name = '*' * (maximum + 1)
      e.active = true
    end

    assert employee.invalid?

    errors = employee.errors.messages
    assert_equal 1, errors[:name].size
    assert_equal 'é muito longo (máximo: 80 caracteres)', errors[:name].first
  end

  test 'should validate active presence' do
    employee = Employee.new do |e|
      e.registry = '12345'
      e.name = 'Goethe'
    end

    assert employee.invalid?

    errors = employee.errors.messages
    assert_equal 1, errors[:active].size
    assert_equal 'não pode ficar em branco', errors[:active].first
  end

  test 'should format registry' do
    e = Employee.new
    e.registry = 12345

    assert_equal '00012345', e.format_registry
  end

  test 'should create an employee' do
  	expected = Employee.count + 1
    Employee.create!(registry: 12345, name: 'Goethe', active: true)
    assert_equal expected, Employee.count
  end
end