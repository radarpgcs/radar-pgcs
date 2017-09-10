module GfeTablesHelper
  def employments_for_selection
    options = Rails.configuration.radarpgcs[:employments].map do |employment|
      [I18n.translate("gfe_tables.employments.#{employment}"), employment]
    end
    options.unshift [ I18n.translate('helpers.select.prompt'), nil]
    options_for_select options
  end
end