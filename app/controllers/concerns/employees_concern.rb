module EmployeesConcern
  extend ActiveSupport::Concern

  def save_view(employee)
    return if employee.registry == current_user.registry

    employee.views = employee.views.to_i + 1
    employee.save

    Auditing.new do |a|
      a.user = current_user
      a.ip = request.remote_ip
      a.event = 'VIEW'
      a.event_date = Time.now
    end.save
  end
end