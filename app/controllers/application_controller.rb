class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # GET /
  def index
    render '/index', layout: false
  end

  # GET /login
  def login
    render '/login', layout: false
  end
end