module ApplicationConcern
  extend ActiveSupport::Concern

  def format_errors(errors)
    msg = '<ul>'
    errors.each do |error|
      msg << "<li>#{error}</li>"
    end
    msg << '</ul>'
    msg.html_safe
  end

  def set_menu_header
    @menu_header = {
      home_path: home_path,
      menu_items: [
        { label: t('menu.header.promotion'), path: promotions_path }
      ]
    }
  end
end