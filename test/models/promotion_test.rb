require 'test_helper'

class PromotionTest < ActiveSupport::TestCase
  test 'should validate employee presence' do
    promotion = Promotion.new do |p|
      p.year = Time.now.year
      p.type = 'PM'
      p.external_staff = false
    end

    assert promotion.invalid?

    errors = promotion.errors.messages
    assert_equal 1, errors[:employee].size
    assert_equal 'não pode ficar em branco', errors[:employee].first
  end

  test 'should validate year presence' do
    promotion = Promotion.new do |p|
      p.employee = Employee.new
      p.type = 'PM'
      p.external_staff = false
    end

    assert promotion.invalid?

    errors = promotion.errors.messages
    assert_equal 2, errors[:year].size
    assert_equal 'não pode ficar em branco', errors[:year].first
  end

  test 'should ensure that year is an integer' do
    promotion = Promotion.new do |p|
      p.employee = Employee.new
      p.year = 2009.4
      p.type = 'PM'
      p.external_staff = false
    end

    assert promotion.invalid?

    errors = promotion.errors.messages
    assert_equal 1, errors[:year].size
    assert_equal 'não é um número inteiro', errors[:year].first
  end

  test 'should ensure that year is >= 2009' do
    promotion = Promotion.new do |p|
      p.employee = Employee.new
      p.year = 2008
      p.type = 'PM'
      p.external_staff = false
    end

    assert promotion.invalid?

    errors = promotion.errors.messages
    assert_equal 1, errors[:year].size
    assert_equal 'deve ser maior ou igual a 2009', errors[:year].first
  end

  test 'should ensure that year is <= current year' do
    promotion = Promotion.new do |p|
      p.employee = Employee.new
      p.year = Time.now.year + 1
      p.type = 'PM'
      p.external_staff = false
    end

    assert promotion.invalid?

    errors = promotion.errors.messages
    assert_equal 1, errors[:year].size
    assert_equal 'deve ser menor ou igual a 2017', errors[:year].first
  end

  test 'should validate type presence' do
    promotion = Promotion.new do |p|
      p.employee = Employee.new
      p.year = Time.now.year
      p.external_staff = false
    end

    assert promotion.invalid?

    errors = promotion.errors.messages
    assert_equal 2, errors[:type].size
    assert_equal 'não pode ficar em branco', errors[:type].first
  end

  test 'should validate type format' do
    promotion = Promotion.new do |p|
      p.employee = Employee.new
      p.year = Time.now.year
      p.type = 'WRONG'
      p.external_staff = false
    end

    assert promotion.invalid?

    errors = promotion.errors.messages
    assert_equal 1, errors[:type].size
    assert_equal 'não é válido', errors[:type].first
  end
end