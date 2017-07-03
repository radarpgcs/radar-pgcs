module PromotionsConcern
  extend ActiveSupport::Concern

  def save_view(employee)
    return if employee.registry == current_user.registry

    employee.views = employee.views.to_i + 1
    employee.save

    Auditing.new do |a|
      a.user = current_user
      a.ip = request.remote_ip
      a.event = 'VIEW'
      a.event_date = Time.now
    end.save
  end

  def parse_promotions_find_params
    opt = {}
    opt[:type] = case params[:type]
      when 'pm' then 'merito'
      when 'merito' then 'merito'
      when 'pts' then 'tempo-servico'
      when 'tempo-servico' then 'tempo-servico'
    end

    opt[:staff] = case params[:staff]
      when 'external' then 'externo'
      when 'externo' then 'externo'
      when 'internal' then 'interno'
      when 'interno' then 'interno'
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

  def parse_query_params
    options = {}
    options[:type] = case params[:type]
      when 'merito' then 'PM'
      when 'tempo-servico' then 'PTS'
    end

    options[:external_staff] = params[:staff] == 'externo'
    options[:year] = params[:year]

    options
  end
end