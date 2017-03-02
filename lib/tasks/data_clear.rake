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
  end
end