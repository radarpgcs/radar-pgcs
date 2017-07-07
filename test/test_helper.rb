ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require Rails.root.join('lib', 'load_fixtures.rb').to_s

class ActiveSupport::TestCase
  
end

_load_fixtures
`rake db:fixtures:promotions`