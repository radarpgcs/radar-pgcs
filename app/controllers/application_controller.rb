require_dependency 'app_logger'
require Rails.root.join 'app', 'errors', 'exceptions.rb'
require Rails.root.join 'app', 'services', 'security_service.rb'
require Rails.root.join 'app', 'services', 'promotions_service.rb'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  include ApplicationConcern
  include LoginConcern
  include ErrorHandlerConcern
  include AppLogger

  before_action :session_expiry, except: [
    :index, :login, :sign_in, :sign_out, :faq, :contact, :send_email,
    :news, :activate_user, :activate_user_account
  ]
  before_action :set_menu_header
  skip_before_action :verify_authenticity_token, :only => [
    :login, :sign_in, :sign_out, :activate_user_account
  ]

  rescue_from Mongoid::Errors::DocumentNotFound, with: :mid_document_not_found
  rescue_from Exceptions::NotAuthorizedException, with: :e_not_authorized_exception
  rescue_from ActionController::InvalidAuthenticityToken, with: :ac_invalid_authenticity_token
  rescue_from ActionController::InvalidAuthenticityToken, with: :ac_request_forgery_exception

  # GET /
  def index
    @menu_header = {
      home_path: '#home',
      menu_items: [
        { label: t('news.title'), path: '#news' },
        { label: t('menu.header.promotion'), path: '#promotion' },
        { label: t('menu.header.gfe_table'), path: '#gfe_table' }
      ]
    }

    if logged_in?
      @news = News.where(version: Rails.configuration.radarpgcs[:version])
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
      flash.clear
      log_in user
    else
      flash[:danger] = t 'login.authentication_failed.message'
      render '/login', layout: false
    end
  end

  # DELETE /logout
  def sign_out
    log_out
  end

  # GET /faq
  def faq
    layout = (logged_in?) ? 'application' : 'public'
    render '/faq', layout: layout
  end

  # GET /contato
  def contact
    layout = (logged_in?) ? 'application' : 'public'
    if logged_in?
      e = Employee.only(:name).find_by(registry: current_user.registry)
      params[:name] = e.name
    end
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

    params[:registry] = current_user.registry if logged_in?
    ApplicationMailer.send_contact_email(params).deliver
    flash[:success] = t 'contact.success'
    
    redirect_to contact_path
  end

  # GET /news
  def news
    html = '<p align="justify">'
    html << "<h4>#{I18n.translate 'news.subtitle', version: Rails.configuration.radarpgcs[:version]}</h4>"
    html << '<ul>'

    News.where(version: Rails.configuration.radarpgcs[:version]).each do |e|
      html << "<li>#{e.message}</li>"
    end

    html << '</ul></p>'
    render html: html.html_safe
  end

  # GET /ativar-conta-usuario/:registry
  def activate_user
    user = User.only(:status).find_by(registry: params[:registry])
    if user.status != 'INACTIVE'
      info "User #{params[:registry]} tried to activate its account with status #{user.status}"
      redirect_to home_path
      return
    end

    @employee = Employee.find_by registry: params[:registry]
    render '/activate_user', layout: 'public'
  end

  # POST /activate_user
  def activate_user_account
    activate_account
  end
end