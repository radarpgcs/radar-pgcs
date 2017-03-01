namespace :db do
  namespace :clear do

    desc 'Delete all data from employees collection'
    task employees: :environment do
      puts "Removing #{Employee.count} record(s) from employees collection."
      Employee.delete_all
    end
  end
end