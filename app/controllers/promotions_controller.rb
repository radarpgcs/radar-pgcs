class PromotionsController < ApplicationController
  before_action :session_expiry, :set_menu_header

  def index
    @menu_header = {
      home_path: home_path,
      menu_items: [
        { label: t('.menu.pgcs'), path: '#definition' },
        { label: t('.menu.search'), path: '#search' }
      ]
    }
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