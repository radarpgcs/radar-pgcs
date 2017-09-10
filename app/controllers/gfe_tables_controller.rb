class GfeTablesController < ApplicationController
  before_action :session_expiry, :set_menu_header

  # GET /dados-consolidados/tabela-gfe
  def index
    _build_home_menu_header
  end

  private
  def _build_home_menu_header
    @menu_header = {
      home_path: home_path,
      menu_items: [
        { label: t('gfe_tables.index.menu.search'), path: '#search' },
        { label: t('gfe_tables.index.menu.gfe'), path: '#definition' }
      ]
    }
  end
end