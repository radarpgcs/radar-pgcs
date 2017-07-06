module EmployeesHelper
  REGIONALS = {
    'BHE' => 'Belo Horizonte',
    'BLM' => 'Belém',
    'BSA' => 'Brasília',
    'CTA' => 'Curitiba',
    'FLA' => 'Fortaleza',
    'FNS' => 'Florianópolis',
    'PAE' => 'Porto Alegre',
    'RCE' => 'Recife',
    'RJO' => 'Rio de Janeiro',
    'SDR' => 'Salvador',
    'SPO' => 'São Paulo'
  }

  def format_registry(employee)
    return if employee.nil? || employee.registry.nil?

    formatted = employee.registry.to_s
    while formatted.size < 8 do
      formatted = '0' + formatted
    end

    return formatted
  end

  def format_regional(employee)
    return unless employee
    REGIONALS[employee.regional]
  end

  def stars(employee, window = 3)
    return unless employee

    employee = Employee.find_by(registry: employee) if employee.is_a? String
    proms = employee.promotions.order(year: :asc).select { |p| p.type == 'PM' }
    count = 0

    proms.collect do |p|
      star = image_tag 'star.png', title: I18n.translate('employees.star.title', year: p.year)
      count += 1
      
      if count == window
        star << '<br/>'.html_safe
        count = 0
      end

      star
    end.join.html_safe
  end

  def promotions_board(employee, window = 10)
    return unless employee

    count = 0
    row = ''
    container = ''

    _build_promotion_divs(employee).each do |div|
      row = '<div class="row">' if count == 0
      row << div

      if (count += 1) >= window
        row << '</div>'
        container << row
        count = 0
      end
    end

    if count > 0
      row << '</div>'
      container << row
    end
    container.html_safe
  end

  def payment_reference(payment)
    month = '0'<<(payment.month.to_s).sub(/\A0{2}/, '0')
    "#{month}/#{payment.year}"
  end

  def estimate_gfe(employee)
    return unless employee.employment
    
    gfe = _calculate_gfe employee
    acceptable_diff = 10_000_000
    estimated_gfe = nil

    _find_next_gfes(employee, gfe).each do |g|
      diff = (gfe - g).abs
      acceptable_diff = diff
      if diff < acceptable_diff
        acceptable_diff = diff
        estimated_gfe = g
      end
    end

    estimated_gfe
  end

  def base_salary(employee)
    return unless employee.reference
    
    reference = /\A(\d{3}-[0-9E]{1})([AB]{1})\z/.match(employee.reference)
    base_reference = reference.captures.first
    step = reference.captures.last
    last_year = 0
    scale = nil
    current_act = Rails.configuration.radarpgcs[:current_act]

    SalaryScale.where(scale: base_reference, act: current_act).select do |s|
      year = /\A\d{4}-(\d{4})\z/.match(s.act).captures.first.to_i
      last_year = year
      if year > last_year
        last_year = year
        scale = s
      end
    end

    (step.upcase == 'A') ? scale.step_a : scale.step_b
  end

  private
  def _build_promotion_divs(employee)
    promotions = {}
    employee.promotions.each { |p| promotions[p.year] = p.type }
    first_year = _first_year employee
    last_year = ENV['LAST_PROMOTION_YEAR'].to_i

    divs = []
    (first_year..last_year).each do |year|
      if promotions[year] == 'PTS'
        divs << _pts_div(year)
      elsif promotions[year] == 'PM'
        divs << _pm_div(year)
      else
        divs << _no_promotion_div(year)
      end
    end

    divs
  end

  def _pm_div(year)
    html = "<h4>#{year}</h4>"
    html << image_tag('thumbs-up.png', title: I18n.translate('employees.thumbs.up'))
    _promotion_div html
  end

  def _pts_div(year)
    html = "<h4>#{year}</h4>"
    html << image_tag('thumbs-down.png', title: I18n.translate('employees.thumbs.down'))
    _promotion_div html
  end

  def _no_promotion_div (year)
    html = "<h4>#{year}</h4>"
    html << image_tag('banana.png', title: I18n.translate('employees.thumbs.banana'))
    _promotion_div html
  end

  def _promotion_div(inner_html)
    div = "<div class=\"col-md-1\" style=\"border: solid;\">"
    div << inner_html
    div << '</div>'
  end

  def _first_year(employee)
    first_year = nil
    if employee.hiring_date
      if employee.hiring_date.year >= ENV['FIRST_PROMOTION_YEAR'].to_i
        first_year = employee.hiring_date.year
      end
    end

    return ENV['FIRST_PROMOTION_YEAR'].to_i unless first_year
    first_year
  end

  def _calculate_gfe(employee)
    r = employee.payments.last.net_salary
    rbs = base_salary employee
    aqu = _additional_by_qualification(employee, rbs)
    anu = _additional_by_year(employee, rbs)

    ((r - rbs) - (aqu + anu))
  end

  def _find_next_gfes(employee, gfe)
    lesser = GfeTable.where(
      act: Rails.configuration.radarpgcs[:current_act],
      employment: employee.employment, 'value.lte' => gfe
    ).limit(2)
    greater = GfeTable.where(
      act: Rails.configuration.radarpgcs[:current_act],
      employment: employee.employment, 'value.gte' => gfe
    ).limit(2)

    greater.merge lesser
  end

  def _additional_by_qualification(employee, base_salary)
    return unless employee.category
    category = employee.category.sub ' - PGCS', ''

    percentual = case category
      when 'CLASSE 1' then 15
      when 'CLASSE 2' then 20
      when 'CLASSE 3' then 25
    end

    base_salary + (base_salary * percentual / 100)
  end

  def _additional_by_year(employee, base_salary)
    return unless employee.hiring_date

    years = _count_working_years employee
    additional = base_salary.dup

    years.times { additional += (base_salary * 1 / 100) }
    additional
  end

  def _count_working_years(employee)
    return unless employee.hiring_date

    today = Time.now
    in_date = employee.hiring_date
    years = 0

    (in_date.year..today.year).each do |year|
      if year < today.year
        years += 1
      else
        if employee.in_date.month > today.month
          years += 1
        elsif (employee.in_date.month == today.month) && (employee.in_date.day >= today.day)
          years += 1
        end
      end
    end

    years
  end
end