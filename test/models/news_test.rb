require 'test_helper'

class NewsTest < ActiveSupport::TestCase
  test 'should not be equal' do
    news = News.new version: '0.1.0'

    n = nil
    assert_not news == n

    n = News.new
    assert_not news == n
  end

  test 'should be equal' do
    news = News.new version: '0.1.0'

    assert news == news
    n = news.dup
    assert news == n

    n = News.new version: '0.1.0'
    assert news == n

    news.message = 'testing'
    assert_not news == n

    n.message = news.message.dup
    assert news == n
  end

  test 'should validate version presence' do
    news = News.new do |n|
      n.message = 'testing'
    end

    assert news.invalid?

    errors = news.errors.messages
    assert_equal 2, errors[:version].size
    assert_equal 'não pode ficar em branco', errors[:version].first
  end

  test 'should validate version format' do
    news = News.new do |n|
      n.version = '0b12.34.2'
      n.message = 'testing'
    end

    assert news.invalid?

    errors = news.errors.messages
    assert_equal 1, errors[:version].size
    assert_equal 'não é válido', errors[:version].first
  end

  test 'should validate message presence' do
    news = News.new do |n|
      n.version = '0.1.0'
    end

    assert news.invalid?

    errors = news.errors.messages
    assert_equal 2, errors[:message].size
    assert_equal 'não pode ficar em branco', errors[:message].first
  end

  test 'should validate message minimum size' do
    minimum = 3
    news = News.new do |n|
      n.version = '0.1.0'
      n.message = 'ok'
    end

    assert news.invalid?

    errors = news.errors.messages
    assert_equal 1, errors[:message].size
    assert_equal "é muito curto (mínimo: #{minimum} caracteres)", errors[:message].first
  end

  test 'should validate message maximum size' do
    maximum = 300
    news = News.new do |n|
      n.version = '0.1.0'
      n.message = ('0' * (maximum + 1))
    end

    assert news.invalid?

    errors = news.errors.messages
    assert_equal 1, errors[:message].size
    assert_equal "é muito longo (máximo: #{maximum} caracteres)", errors[:message].first
  end
end