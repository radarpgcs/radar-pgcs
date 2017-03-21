class EmployeesController < ApplicationController
	before_action :session_expiry, :set_menu_header

	# GET /empregados/:registry
	def show
		@employee = Employee.find_by registry: params[:registry]
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