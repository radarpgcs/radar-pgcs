namespace :db do
  namespace :fixtures do
    
    desc 'Load fixtures into database'
    task load: :environment do
      require Rails.root.join('lib', 'load_fixtures.rb').to_s
      _load_fixtures
    end

    desc 'Create promotions based on existing employees'
    task promotions: :environment do
      Promotion.delete_all

      seed = Employee.all.count / 3
      employees = {}
      Employee.all.only(:registry).each { |e| employees[e.registry] = {} }

      (2009..Time.now.year).each do |year|
        for i in (0..seed-1)
          %w(PM PTS).each do |tp|
            index = Random.rand(employees.size)
            while employees[employees.keys[index]][year].nil? do
              employees[employees.keys[index]][year] = tp
            end
          end
        end
      end
      
      employees.each do |id, proms|
        proms.each do |year, type|
          Promotion.create(
            employee: Employee.find_by(registry: id),
            year: year,
            type: type,
            external_staff: Random.rand(3) < 2
          )
        end
      end
    end
  end
end