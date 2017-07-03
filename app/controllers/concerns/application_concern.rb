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
end