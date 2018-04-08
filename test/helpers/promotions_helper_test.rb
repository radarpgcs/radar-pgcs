class PromotionsHelperTest < ActionView::TestCase
  include PromotionsHelper

  test 'should get a list of options to select component with all years' do
    first = Rails.configuration.radarpgcs[:first_promotion_year]
    last = Rails.configuration.radarpgcs[:last_promotion_year]
    options = years_for_selection.split("\n")

    assert options.first.match(%r(<option value="">Por favor selecione</option>))
    options.delete_at 0

    years = (first..last).map { |year| year }
    for i in 0..(years.size - 1)
      puts options[i]
      puts first
      puts last
      assert_equal options[i], "<option value=#{years[i]}>#{years[i]}<\/option>"
      #assert options[i].match(/<option value="#{years[i]}">#{years[i]}<\/option>/)
    end
  end
end