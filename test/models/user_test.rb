require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'should not be equal' do
    user = User.new registry: 12345

    u = nil
    assert_not user == u

    u = User.new
    assert_not user == u
  end

  test 'should be equal' do
    user = User.new registry: 12345

    assert user == user
    u = user.dup
    assert user == u

    u = User.new registry: 12345
    assert user == u
  end

  test 'should validate registry presence' do
    user = User.new do |u|
      u.password = '12345'
      u.salt_number = '54321'
      u.status = 'ACTIVE'
    end

    assert user.invalid?

    errors = user.errors.messages
    assert_equal 1, errors[:registry].size
    assert_equal 'não pode ficar em branco', errors[:registry].first
  end

  test 'should validate password presence' do
    user = User.new do |u|
      u.registry = '12345'
      u.salt_number = '54321'
      u.status = 'ACTIVE'
    end

    assert user.invalid?

    errors = user.errors.messages
    assert_equal 2, errors[:password].size
    assert_equal 'não pode ficar em branco', errors[:password].first
  end

  test 'should validate password minimum size' do
    minimum = 5
    user = User.new do |u|
      u.registry = '12345'
      u.password = ('0' * (minimum - 1))
      u.salt_number = '54321'
      u.status = 'ACTIVE'
    end

    assert user.invalid?

    errors = user.errors.messages
    assert_equal 1, errors[:password].size
    assert_equal "é muito curto (mínimo: #{minimum} caracteres)", errors[:password].first
  end

  test 'should validate password maximum size' do
    maximum = 20
    user = User.new do |u|
      u.registry = '12345'
      u.password = ('0' * (maximum + 1))
      u.salt_number = '54321'
      u.status = 'ACTIVE'
    end

    assert user.invalid?

    errors = user.errors.messages
    assert_equal 1, errors[:password].size
    assert_equal "é muito longo (máximo: #{maximum} caracteres)", errors[:password].first
  end

  test 'should validate status presence' do
    user = User.new do |u|
      u.registry = '12345'
      u.password = '12345'
      u.salt_number = '54321'
    end

    assert user.invalid?

    errors = user.errors.messages
    assert_equal 2, errors[:status].size
    assert_equal 'não pode ficar em branco', errors[:status].first
  end

  test 'should validate status value inclusion' do
    user = User.new do |u|
      u.registry = '12345'
      u.password = '12345'
      u.salt_number = '54321'
      u.status = 'WRONG'
    end

    assert user.invalid?

    errors = user.errors.messages
    assert_equal 1, errors[:status].size
    assert_equal 'não está incluído na lista', errors[:status].first
  end

  test 'should validate roles presence' do
    user = User.new do |u|
      u.registry = '12345'
      u.password = '12345'
      u.salt_number = '54321'
      u.status = 'ACTIVE'
    end

    assert user.invalid?

    errors = user.errors.messages
    assert_equal 1, errors[:roles].size
    assert_equal 'não pode ficar em branco', errors[:roles].first
  end

  test 'should validate roles minimum size' do
    user = User.new do |u|
      u.registry = '12345'
      u.password = '12345'
      u.salt_number = '54321'
      u.status = 'ACTIVE'
      u.roles = []
    end

    assert user.invalid?

    errors = user.errors.messages
    assert_equal 1, errors[:roles].size
    assert_equal 'deve ser uma relação de pelo menos um elemento', errors[:roles].first
  end

  test 'should validate roles maximum size' do
    user = User.new do |u|
      u.registry = '12345'
      u.password = '12345'
      u.salt_number = '54321'
      u.status = 'ACTIVE'
      u.roles = %w(ADMINISTRATOR COLLABORATOR MEMBER MEMBER)
    end

    assert user.invalid?

    errors = user.errors.messages
    assert_equal 1, errors[:roles].size
    assert_equal 'deve ser uma relação com no máximo 3 elementos', errors[:roles].last
  end

  test 'should validate roles inclusion' do
    user = User.new do |u|
      u.registry = '12345'
      u.password = '12345'
      u.salt_number = '54321'
      u.status = 'ACTIVE'
      u.roles = %w(ADMINISTRATOR COLLABORATOR WRONG)
    end

    assert user.invalid?

    errors = user.errors.messages
    assert_equal 1, errors[:roles].size
    assert_equal 'esperava encontrar uma lista contendo um destes valores: ADMINISTRATOR COLLABORATOR MEMBER', errors[:roles].last
  end

  test 'should save a user' do
    registry = 123456
    user = User.find_by(registry: registry)
    user.delete if user
    password = '12345'

    user = User.new do |u|
      u.registry = registry
      u.password = password
      u.status = 'ACTIVE'
      u.roles = %w(ADMINISTRATOR COLLABORATOR MEMBER)
    end

    user.save
    assert_not_nil user.id
    assert_equal registry, user.registry
    assert_equal 'ACTIVE', user.status
    assert_equal %w(ADMINISTRATOR COLLABORATOR MEMBER), user.roles
    assert_not_nil user.salt_number

    password_hash = Services::Security.generate_hash password, user.salt_number
    assert_equal password_hash, user.password

    salt_number = user.salt_number.dup
    user.save

    assert_equal password_hash, user.password
    assert_equal salt_number, user.salt_number
  end
end