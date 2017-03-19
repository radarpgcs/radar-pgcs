module PromotionsConcern
  extend ActiveSupport::Concern

  def parse_promotions_find_params
    opt = {}
    opt[:type] = case params[:promotion]
      when 'pm' then 'merito'
      when 'pts' then 'tempo-servico'
    end

    opt[:staff] = case params[:staff]
      when 'external' then 'externo'
      when 'internal' then 'interno'
    end

    opt[:year] = params[:year].to_i if params[:year]

    opt
  end

  def validate_promotions_find_params(options = {})
    errors = []
    errors << t('promotions.index.search.validation.promotion') if options[:type].nil?
    errors << t('promotions.index.search.validation.staff') if options[:staff].nil?

    invalid_year = options[:year].nil? || options[:year] < 2009 || options[:year] > Time.now.year
    errors << t('promotions.index.search.validation.year') if invalid_year

    errors
  end

  def format_errors(errors)
    msg = '<ul>'
    errors.each do |error|
      msg << "<li>#{error}</li>"
    end
    msg << '</ul>'
    msg.html_safe
  end
end