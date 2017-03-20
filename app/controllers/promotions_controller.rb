class PromotionsController < ApplicationController
  before_action :session_expiry, :set_menu_header

  include PromotionsConcern

  # GET /promocoes
  def index
    _build_home_menu_header
    @promotions = Services::Promotions.get_promotion_totals
  end

  # GET /pesquisar-promocoes
  def find
    options = parse_promotions_find_params
    errors = validate_promotions_find_params options

    unless errors.empty?
      flash[:danger] = format_errors errors
      _build_home_menu_header
      @promotions = Services::Promotions.get_promotion_totals
      render '/promotions/index'
      return
    end

    redirect_to list_promotions_path(type: options[:type],
      staff: options[:staff], year: options[:year])
  end

  # GET /promocoes/:type/:staff/:year
  def list
    @options = parse_promotions_find_params
    errors = validate_promotions_find_params @options

    unless errors.empty?
      flash[:danger] = format_errors errors
      _build_home_menu_header
      @promotions = Services::Promotions.get_promotion_totals
      render '/promotions/index'
      return
    end

    flash.clear
    @options = parse_query_params
    @promotions = Promotion.where(@options).page(params[:page])
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

  def _build_home_menu_header
    @menu_header = {
      home_path: home_path,
      menu_items: [
        { label: t('promotions.index.menu.pgcs'), path: '#definition' },
        { label: t('promotions.index.menu.report'), path: '#report' },
        { label: t('promotions.index.menu.search'), path: '#search' }
      ]
    }
  end
end