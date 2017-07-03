class EmployeesController < ApplicationController
  include EmployeesConcern
  
	before_action :session_expiry, :set_menu_header

	# GET /empregados/:registry
	def show
		@employee = Employee.find_by registry: params[:registry]
    @payment = @employee.payments.last

    save_view @employee
	end

  # GET /empregados/:registry/historico-remuneracoes
  def payment_history
    @employee = Employee.only(:id, :registry, :name).find_by registry: params[:registry]
    @payments = Payment.where(employee: @employee)
  end

	private
  def set_menu_header
    @menu_header = {
      home_path: home_path,
      menu_items: [
        { label: t('menu.header.promotion'), path: promotions_path }
      ]
    }
  end
end