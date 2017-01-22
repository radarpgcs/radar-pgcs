require Rails.root.join 'app', 'services', 'security_service.rb'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include LoginConcern

  # GET /
  def index
    render '/index', layout: false
  end

  # GET /login
  def login
    render '/login', layout: false
  end

  # POST /authenticate
  def sign_in
    user = authenticate_login params[:identity], params[:password]
    if user
      log_in user
      redirect_to caller_url
      flash.clear

      Rails.logger.info "User #{user.registry} has just signed in."
    else
      flash[:danger] = t 'login.authentication_failed.message'
      render '/login', layout: false
    end
  end

  # DELETE /logout
  def sign_out
    #message = (logged_in?) ? "User #{current_user.cpf} has just signed out." : 'Session destroyed by expiration.'
    #log_out
    #info message
    #redirect_to home_path
  end
end