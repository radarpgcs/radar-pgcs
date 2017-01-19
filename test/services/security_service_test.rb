require 'test_helper'
require Rails.root.join 'app', 'services', 'security_service.rb'

class SecurityServiceTest < ActiveSupport::TestCase

  include Services

  test 'should generate a salt number' do
    salt = Security.generate_salt_number
    assert salt.is_a? String
    assert_equal salt.size, 45

    salt = Security.generate_salt_number 10
    assert salt.is_a? String
    assert_equal salt.size, 10
  end

  test 'should generate a password hash' do
    expected = 'x+YVzRf7cMl2JZT9Pq+/D1rkX+Id7t0strYZg1cucUqOs7THrMrtoxtqQya3QjanUfNk/2cpeDXwQqBWGnNMsw=='
    actual = Security.generate_hash 'raw password', 'salt number'
    
    assert_equal expected, actual
  end
end