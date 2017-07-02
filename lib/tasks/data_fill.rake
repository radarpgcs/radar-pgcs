namespace :db do
  namespace :fill do

    EMPLOYEES_DB_FILE = Rails.root.join 'db', 'dbfiles', 'employees-db.yaml'
    DATA_DIR = Rails.root.join 'tmp', 'employees_extraction', 'data'

    desc 'Fill employees collection'
    task employees: :environment do
      unless File.exist? EMPLOYEES_DB_FILE
        puts "Data file #{EMPLOYEES_DB_FILE} does not exist."
        exit 10
      end

      unless File.exist? DATA_DIR
        puts "Data directory #{DATA_DIR} does not exist."
        exit 20
      end

      Payment.delete_all
      Employee.delete_all

      puts "Loading data file #{EMPLOYEES_DB_FILE}"
      YAML.load_file(EMPLOYEES_DB_FILE).each do |key, values|
        e = Employee.new registry: key, active: true, views: 0
        e.cpf = values['cpf'] if values.instance_of? Hash

        path = File.join DATA_DIR, key.to_s
        unless File.exist? path
          if values.is_a? String
            e.name = values
            e.save!
            next
          end

          values[:matricula] = key.to_s
          File.open(path, 'w') { |io| io.write values.to_yaml }
        end

        fields = YAML.load_file path

        e.name = fields[:nome]
        e.employment = fields[:cargo]
        e.category = fields[:classe]
        e.reference = fields[:referencia]
        e.department = fields[:lotacao]
        e.working_hours = fields[:jornada]
        e.hiring_date = fields[:data_contratacao]

        reg = /\/\w+(BHE|BSA|BLM|CTA|FLA|FNS|PAE|RCE|RJO|SDR|SPO)\/?/.match e.department.to_s
        e.regional = reg.captures.first if reg

        rem = fields[:remuneracao]
        if rem && rem[:bruto]
          p = Payment.new(
            year: rem[:ano], month: rem[:mes], total: rem[:bruto],
            eventual: rem[:eventual], net_salary: rem[:liquido], employee: e
          )
          p.save!
        end

        e.save!
      end
      puts "Employees collection has now #{Employee.count} record(s)."
    end

    desc 'Fill promotions collection'
    task promotions: :environment do
      Promotion.delete_all
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