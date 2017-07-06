namespace :db do
  namespace :fixtures do
    
    desc 'Load fixtures into database'
    task load: :environment do
      require Rails.root.join('lib', 'load_fixtures.rb').to_s
      _load_fixtures
    end
  end
end