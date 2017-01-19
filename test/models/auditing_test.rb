require 'test_helper'

class AuditingTest < ActiveSupport::TestCase
  test 'should validate user presence' do
    auditing = Auditing.new do |a|
      a.event = 'LOGIN'
      a.event_date = Time.now
      a.url = 'http://localhost/test'
    end

    assert auditing.invalid?

    errors = auditing.errors.messages
    assert_equal 1, errors[:user].size
    assert_equal 'não pode ficar em branco', errors[:user].first
  end

  test 'should validate event presence' do
    auditing = Auditing.new do |a|
      a.user = User.new
      a.event_date = Time.now
      a.url = 'http://localhost/test'
    end

    assert auditing.invalid?

    errors = auditing.errors.messages
    assert_equal 2, errors[:event].size
    assert_equal 'não pode ficar em branco', errors[:event].first
  end

  test 'should validate event value inclusion' do
    auditing = Auditing.new do |a|
      a.user = User.new
      a.event = 'WRONG'
      a.event_date = Time.now
      a.url = 'http://localhost/test'
    end

    assert auditing.invalid?

    errors = auditing.errors.messages
    assert_equal 1, errors[:event].size
    assert_equal 'não está incluído na lista', errors[:event].first
  end

  test 'should validate event_date presence' do
    auditing = Auditing.new do |a|
      a.user = User.new
      a.event = 'LOGIN'
      a.url = 'http://localhost/test'
    end

    assert auditing.invalid?

    errors = auditing.errors.messages
    assert_equal 1, errors[:event_date].size
    assert_equal 'não pode ficar em branco', errors[:event_date].first
  end
end