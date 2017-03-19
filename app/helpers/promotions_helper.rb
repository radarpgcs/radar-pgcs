module PromotionsHelper
  def years_for_selection
    options = (2009..Time.now.year).map { |year| [year, year] }
    options.unshift [ I18n.translate('helpers.select.prompt'), nil]
    options_for_select options
  end
end