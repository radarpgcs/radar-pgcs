class PromotionsController < ApplicationController
  before_action :session_expiry, :set_menu_header

  include PromotionsConcern

  # GET /promocoes
  def index
    @menu_header = {
      home_path: home_path,
      menu_items: [
        { label: t('.menu.pgcs'), path: '#definition' },
        { label: t('.menu.search'), path: '#search' }
      ]
    }
  end

  # GET /pesquisar-promocoes
  def find
    options = parse_promotions_find_params
    errors = validate_promotions_find_params options

    unless errors.empty?
      flash[:danger] = format_errors errors
      render '/promotions/index'
      return
    end

    redirect_to list_promotions_path(type: options[:type],
      staff: options[:staff], year: options[:year])
  end

  # GET /promocoes/:type/:staff/:year
  def list

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