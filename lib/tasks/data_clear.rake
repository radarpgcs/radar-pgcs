namespace :db do
  namespace :clear do

    desc 'Delete all data from employees collection'
    task employees: :environment do
      puts "Removing #{Payment.count} record(s) from related collection payments."
      Payment.delete_all

      puts "Removing #{Promotion.count} record(s) from related collection promotions."
      Promotion.delete_all
      
      puts "Removing #{Employee.count} record(s) from employees collection."
      Employee.delete_all
    end

    desc 'Delete all data from payments collection'
    task payments: :environment do
      puts "Removing #{Payment.count} record(s) from payments collection."
      Payment.delete_all
    end

    desc 'Delete all data from promotions collection'
    task promotions: :environment do
      puts "Removing #{Promotion.count} record(s) from promotions collection."
      Promotion.delete_all
    end
  end
end