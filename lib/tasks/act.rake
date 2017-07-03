namespace :act do
  namespace :calc do

    desc 'Calculate and generate GFE table for new ACT'
    task gfe: :environment do
      _validate
      percentage = ENV['PERCENTAGE'].sub(',', '.').to_f
      last_act = get_last_act

      puts "Generating new GFE table about the last ACT: #{last_act}"
      GfeTable.where(act: last_act).each do |gfe|
        new_value = add_percentual gfe.value, percentage
        GfeTable.create!(
          act: ENV['ACT'], employment: gfe.employment,
          level: gfe.level, value: new_value
        )
      end
    end

    desc 'Calculate and generate salary scale for new ACT'
    task salary: :environment do
      _validate
      percentage = ENV['PERCENTAGE'].sub(',', '.').to_f
      last_act = get_last_act

      puts "Generating new salary scale about the last ACT: #{last_act}"
      SalaryScale.where(act: last_act).each do |scale|
        new_step_a = add_percentual scale.step_a, percentage
        new_step_b = add_percentual scale.step_b, percentage

        SalaryScale.create!(
          act: ENV['ACT'], scale: scale.scale,
          step_a: new_step_a, step_b: new_step_b
        )
      end
    end

    private
    def add_percentual(value, percentage)
      percentual = percentage * value / 100
      value + percentual
    end

    def get_last_act
      last_year = 0
      last_act = nil
      GfeTable.only(:act).distinct(:act).each do |act|
        year = /\A\d+-(\d+)\z/.match(act).captures.first.to_i
        last_act = act if year > last_year
      end

      last_act
    end

    def _validate
      raise 'Invalid range year. Must be "yyyy-yyyy".' unless /\A\d{4}-\d{4}\z/ =~ ENV['ACT']
      raise 'Invalid percentage. Must be a decimal like 5,34.' unless /\A\d+[,.]?\d{1,2}\z/ =~ ENV['PERCENTAGE']
    end
  end
end