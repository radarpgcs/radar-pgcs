namespace :db do
  namespace :fill do

    EMPLOYEES_DB_FILE = Rails.root.join 'db', 'dbfiles', 'employees-db.yaml'

    desc 'Fill employees collection'
    task employees: :environment do
      unless File.exist? EMPLOYEES_DB_FILE
        puts "Data file #{EMPLOYEES_DB_FILE} does not exist."
        exit 10
      end

      puts "Loading data file #{EMPLOYEES_DB_FILE}"
      puts "Employees collection has #{Employee.count} record(s)."
      YAML.load_file(EMPLOYEES_DB_FILE).each do |id, fields|
        e = Employee.new registry: id, active: true, views: 0
        if fields.instance_of? Hash
          e.cpf = fields[:cpf]
          e.name = fields[:nome]
          e.employment = fields[:cargo]
          e.category = fields[:classe]
          e.reference = fields[:referencia]
          e.department = fields[:lotacao]
          e.regional = fields[:regional]
          e.hiring_date = fields[:data_contratacao]
        else
          e.name = fields
        end
        e.save!
      end
      puts "Employees collection has now #{Employee.count} record(s)."
    end

    desc 'Fill promotions collection'
    task promotions: :environment do
      (2009..Time.now.year).each do |year|
        file = Rails.root.join('db', "dbfiles", "promotions-db-#{year}.yaml")
        next unless File.exist? file
        puts "Reading file #{file}"

        data = YAML.load_file(file)
        data.each_key do |year|
          data[year].each_key do |type|
            data[year][type].each_key do |staff_location|
              data[year][type][staff_location].each do |id|
                employee = Employee.find_by(registry: id.to_i)
                raise "There isn't any employee registered with id #{id}." if employee.nil?

                Promotion.create!(
                  employee: employee, year: year, type: type,
                  external_staff: (staff_location == 'quadro_externo')
                )
              end
            end
          end
        end
      end
    end
  end
end