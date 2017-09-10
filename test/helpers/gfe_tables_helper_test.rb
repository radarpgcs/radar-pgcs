class GfeTablesHelperTest < ActionView::TestCase
  include GfeTablesHelper

  test 'should get a list of options to select component with all employments' do
    options = employments_for_selection.split("\n")

    assert options.first.match(%r(<option value="">Por favor selecione</option>))
    options.delete_at 0

    %w(ANALISTA TECNICO AUXILIAR).each do |employment|
      translation = I18n.translate("gfe_tables.employments.#{employment}")
      assert options.include?("<option value=\"#{employment}\">#{translation}</option>")
    end
  end
end