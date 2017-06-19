# encoding: utf-8

module Crawler
  require 'capybara'
  require 'capybara/dsl'
  require 'capybara-webkit'
  require 'yaml'

  class EmployeeRobot
    include Capybara::DSL

    URL = 'https://remuneracao.serpro.gov.br'

    def init
      _configure_capybara
      _got_to_website
    end

    def employee_snapshot(options)
      _find_employee options
    end

    private
    def _configure_capybara
      Capybara.current_driver = :webkit

      Capybara::Webkit.configure do |config|
        config.allow_unknown_urls
        config.allow_url(URL)
      end
    end

    def _got_to_website
      puts "Access web site #{URL}"
      page.driver.browser.ignore_ssl_errors
      visit(URL)
    end

    def _find_employee(options)
      puts "Browse to fetch #{options[:query]}"
      type = 'tipo' << ((options[:type] == :cpf) ? 'CPF' : 'Nome')
      choose type
      fill_in 'busca', :with => options[:query]
      click_on 'Pesquisar'

      _get_data
    end

    def _get_data
      data = _get_functional_data
      find(:xpath, "//div[@class='div_tipo_visualiza_dados']/a/span[text() = 'Informações Financeiras']/..").click
      data.merge _get_financial_data
    end

    def _get_functional_data
      data = {}
      data[:nome] = find(:xpath, "//tr/th[text() = 'NOME']/../td").text
      data[:matricula] = find(:xpath, "//tr/th[text() = 'MATRÍCULA']/../td").text
      data[:cargo] = find(:xpath, "//tr/th[text() = 'CARGO']/../td").text
      data[:classe] = find(:xpath, "//tr/th[text() = 'CLASSE']/../td").text
      data[:referencia] = find(:xpath, "//tr/th[text() = 'REFERÊNCIA']/../td").text
      data[:lotacao] = find(:xpath, "//tr/th[text() = 'CPF']/../../tr/th[text() = 'LOTAÇÃO']/../td").text # avoid ambiguous matching
      data[:jornada] = find(:xpath, "//tr/th[text() = 'JORNADA']/../td").text
      data[:data_contratacao] = find(:xpath, "//tr/th[text() = 'DATA CONTRATAÇÃO']/../td").text
      
      if has_xpath? "//h1[text() = 'Função de confiança']"
        data[:funcao_confianca] = find(:xpath, "//tr/th[text() = 'FUNÇÃO DE CONFIANÇA']/../td").text
      end

      data
    end

    def _get_financial_data
      time = Time.now
      hash = {}
      hash[:ano] = time.year
      hash[:mes] = time.month
      hash[:bruto] = find(:xpath, "//tr[@class='remuneracao_valor']/td[2]").text.gsub(/[A-Z\s$]/, '')
      hash[:liquido] = find(:xpath, "//tr/td[@class='liquido'][2]").text.gsub(/[A-Z\s$]/, '')
      
      { remuneracao: hash }
    end
  end
end