module Crawler
  RAILS_APP_DIR = File.expand_path '../../..', __FILE__
  WORKING_DIR = File.join RAILS_APP_DIR, 'tmp', 'employees_extraction'
  DATA_DIR = File.join WORKING_DIR, 'data'
  BUCKET_SIZE = 10

  require File.join RAILS_APP_DIR, 'lib', 'crawler', 'employee_robot.rb'
  require 'json'

  def self._get_employees
    path = File.join WORKING_DIR, 'read_ids'
    read_ids = (File.exist? path) ? File.readlines(path) : {}

    records = JSON.parse File.read(File.join RAILS_APP_DIR, 'db', 'dbfiles', 'employees.json')
    read_ids.each { |id| records.delete id }
    records
  end

  def self._get_options(value)
    if value.is_a? Hash
      if value['cpf']
        { type: :cpf, query: value['cpf'] }
      else
        { type: :nome, query: value['nome'] }
      end
    else
      { type: :nome, query: value }
    end
  end

  def self._flush(employees, statuses)
    _flush_employees employees
    _flush_statuses statuses

    employees.clear
    statuses.clear
  end

  def self._flush_employees(employees)
    employees.each do |record|
      next if record.empty?
      path = File.join(DATA_DIR, record[:matricula])
      File.open(path, 'w') { |io| io.write record.to_yaml }
    end
  end

  def self._flush_statuses(statuses)
    success, failures = [], []
    statuses.each do |record|
      if record[:done]
        success << record[:id]
      else
        failures << "#{record[:id]}: #{record[:message]}"
      end
    end

    path = File.join WORKING_DIR, 'read_ids'
    File.open(path, 'a') { |io| io.write success.join("\n") }

    path = File.join WORKING_DIR, 'failures'
    File.open(path, 'a') { |io| io.write failures.join("\n") }
  end

  Dir.mkdir WORKING_DIR unless File.exist? WORKING_DIR
  Dir.mkdir DATA_DIR unless File.exist? DATA_DIR

  employees = _get_employees
  robot = EmployeeRobot.new
  robot.init
  records, statuses = [], []
  count = 0

  puts "Searching about #{employees.size} employees."
  exit 0
  employees.each do |key, value|
    begin
      data = robot.employee_snapshot _get_options(value)
      status = { id: key, done: true }
    rescue Exception => ex
      data = {}
      status = { id: key, done: false, message: ex.message }
    end

    records << data
    statuses << status
    count += 1

    if count >= BUCKET_SIZE
      _flush records, statuses
      count = 0
    end
  end
end