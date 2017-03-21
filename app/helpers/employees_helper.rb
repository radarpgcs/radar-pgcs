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
    proms = employee.promotions.select { |p| p.type == 'PM' }
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

  private
  def _build_promotion_divs(employee)
    promotions = {}
    employee.promotions.each { |p| promotions[p.year] = p.type }
    first_year = (employee.hiring_date) ? employee.hiring_date.year : ENV['FIRST_PROMOTION_YEAR'].to_i
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
end