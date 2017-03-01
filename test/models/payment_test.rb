require 'test_helper'

class PaymentTest < ActiveSupport::TestCase
  test 'should not be equal' do
    payment = Payment.new year: Time.now.year

    p = nil
    assert_not payment == p

    p = Payment.new
    assert_not payment == p

    p.year = payment.year
    payment.month = Time.now.month
    assert_not payment == p

    p.month = payment.month
    payment.total = 1
    assert_not payment == p

    p.total = payment.total
    payment.eventual = 0.1
    assert_not payment == p
  end

  test 'should be equal' do
    p1 = Payment.new year: Time.now.year
    p2 = Payment.new year: Time.now.year

    assert p1 == p2

    p1.month = Time.now.month
    p2.month = Time.now.month
    assert p1 == p2

    p1.total = 3.2
    p2.total = 3.2
    assert p1 == p2

    p1.eventual = 0.4
    p2.eventual = 0.4
    assert p1 == p2
  end

  test 'should validate employee presence' do
    payment = Payment.new do |p|
      p.year = Time.now.year
      p.month = Time.now.month
      p.total = 54
    end

    assert payment.invalid?

    errors = payment.errors.messages
    assert_equal 1, errors[:employee].size
    assert_equal 'não pode ficar em branco', errors[:employee].first
  end

  test 'should validate year presence' do
    payment = Payment.new do |p|
      p.employee = Employee.new
      p.month = Time.now.month
      p.total = 54
    end

    assert payment.invalid?

    errors = payment.errors.messages
    assert_equal 2, errors[:year].size
    assert_equal 'não pode ficar em branco', errors[:year].first
  end

  test 'should ensure that year is an integer' do
    payment = Payment.new do |p|
      p.employee = Employee.new
      p.year = 1.2
      p.month = Time.now.month
      p.total = 54
    end

    assert payment.invalid?

    errors = payment.errors.messages
    assert_equal 1, errors[:year].size
    assert_equal 'não é um número inteiro', errors[:year].first
  end

  test 'should ensure that year is >= 2016' do
    payment = Payment.new do |p|
      p.employee = Employee.new
      p.year = 2015
      p.month = Time.now.month
      p.total = 54
    end

    assert payment.invalid?

    errors = payment.errors.messages
    assert_equal 1, errors[:year].size
    assert_equal 'deve ser maior ou igual a 2016', errors[:year].first
  end

  test 'should ensure that year is <= current year' do
    payment = Payment.new do |p|
      p.employee = Employee.new
      p.year = Time.now.year + 1
      p.month = Time.now.month
      p.total = 54
    end

    assert payment.invalid?

    errors = payment.errors.messages
    assert_equal 1, errors[:year].size
    assert_equal 'deve ser menor ou igual a 2017', errors[:year].first
  end

  test 'should validate month presence' do
    payment = Payment.new do |p|
      p.employee = Employee.new
      p.year = Time.now.year
      p.total = 54
    end

    assert payment.invalid?

    errors = payment.errors.messages
    assert_equal 2, errors[:month].size
    assert_equal 'não pode ficar em branco', errors[:month].first
  end

  test 'should ensure that month is an integer' do
    payment = Payment.new do |p|
      p.employee = Employee.new
      p.year = Time.now.year
      p.month = 1.2
      p.total = 54
    end

    assert payment.invalid?

    errors = payment.errors.messages
    assert_equal 1, errors[:month].size
    assert_equal 'não é um número inteiro', errors[:month].first
  end

  test 'should ensure that month is >= 1' do
    payment = Payment.new do |p|
      p.employee = Employee.new
      p.year = Time.now.year
      p.month = 0
      p.total = 54
    end

    assert payment.invalid?

    errors = payment.errors.messages
    assert_equal 1, errors[:month].size
    assert_equal 'deve ser maior ou igual a 1', errors[:month].first
  end

  test 'should ensure that month is <= 12' do
    payment = Payment.new do |p|
      p.employee = Employee.new
      p.year = Time.now.year
      p.month = 13
      p.total = 54
    end

    assert payment.invalid?

    errors = payment.errors.messages
    assert_equal 1, errors[:month].size
    assert_equal 'deve ser menor ou igual a 12', errors[:month].first
  end

  test 'should validate total presence' do
    payment = Payment.new do |p|
      p.employee = Employee.new
      p.year = Time.now.year
      p.month = Time.now.month
    end

    assert payment.invalid?

    errors = payment.errors.messages
    assert_equal 2, errors[:total].size
    assert_equal 'não pode ficar em branco', errors[:total].first
  end

  test 'should ensure that total is a number' do
    payment = Payment.new do |p|
      p.employee = Employee.new
      p.year = Time.now.year
      p.month = Time.now.month
      p.total = 'five'
    end

    assert payment.invalid?

    errors = payment.errors.messages
    assert_equal 1, errors[:total].size
    assert_equal 'não é um número', errors[:total].first
  end

  test 'should ensure that total is > 0' do
    payment = Payment.new do |p|
      p.employee = Employee.new
      p.year = Time.now.year
      p.month = Time.now.month
      p.total = 0
    end

    assert payment.invalid?

    errors = payment.errors.messages
    assert_equal 1, errors[:total].size
    assert_equal 'deve ser maior que 0', errors[:total].first
  end
end