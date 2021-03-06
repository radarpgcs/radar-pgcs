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
            year: rem[:ano], month: rem[:mes], total: parse_float(rem[:bruto]),
            eventual: parse_float(rem[:eventual]), net_salary: parse_float(rem[:liquido]),
            employee: e
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

    desc 'Fill gfe_tables collection'
    task gfe_tables: :environment do
      GfeTable.delete_all
      file = Rails.root.join('db', "dbfiles", "gfe-table-act-2015-2016-db.yaml")
      puts "Reading file #{file}"
      YAML.load_file(file).each do |act, table|
        table.each do |employment, levels|
          levels.each do |level, value|
            GfeTable.create!(
              act: act, employment: employment,
              level: level, value: value
            )
          end
        end
      end
    end

    desc 'Fill salary_scales collection'
    task salary_scales: :environment do
      SalaryScale.delete_all
      file = Rails.root.join('db', "dbfiles", "salary-scale-act-2015-2016-db.yaml")
      puts "Reading file #{file}"
      YAML.load_file(file).each do |act, table|
        table.each do |scale, steps|
          SalaryScale.create!(act: act, scale: scale, step_a: steps['A'], step_b: steps['B'])
        end
      end
    end

    def parse_float(value)
      return unless value
      return value if value.is_a? Float
      return value.to_s.to_f if value.to_s.match /\A\d+\.\d{2}\z/

      value.to_s.sub('.', '').sub(',', '.').to_f
    end
  end
end