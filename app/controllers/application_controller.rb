require Rails.root.join 'app', 'services', 'security_service.rb'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include LoginConcern

  # GET /
  def index
    if logged_in?
      @news = News.where(version: ENV['APP_VERSION'])
      render '/home'
    else
      render '/index', layout: false
    end
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
      render '/login', layout: 'public'
    end
  end

  # DELETE /logout
  def sign_out
    message = (logged_in?) ? "User #{current_user.registry} has just signed out." : 'Session destroyed by expiration.'
    log_out
    Rails.logger.info message
    redirect_to home_path
  end

  # GET /faq
  def faq
    layout = (logged_in?) ? 'application' : 'public'
    render '/faq', layout: layout
  end

  # GET /contato
  def contact
    layout = (logged_in?) ? 'application' : 'public'
    render '/contact', layout: layout
  end

  # POST /send_email
  def send_email
    unless verify_recaptcha
      layout = (logged_in?) ? 'application' : 'public'
      flash[:danger] = flash[:recaptcha_error].dup
      flash.delete(:recaptcha_error)
      return render '/contact', layout: layout
    end


  end

  # GET /news
  def news
    html = '<p align="justify">'
    html << "<h4>#{I18n.translate 'news.subtitle', version: ENV['APP_VERSION']}</h4>"
    html << '<ul>'

    News.where(version: ENV['APP_VERSION']).each do |e|
      html << "<li>#{e.message}</li>"
    end

    html << '</ul></p>'
    render html: html.html_safe
  end
end