module Services
  class Promotions
  	@@promotion_totals = nil

    class << self
      def get_promotion_totals
        return @@promotion_totals if @@promotion_totals

        last_year = Rails.configuration.radarpgcs[:last_promotion_year]
        @@promotion_totals = {}
        
        (2009..last_year.to_i).each do |year|
          @@promotion_totals[year] = { pm: {}, pts: {} }
          @@promotion_totals[year][:pm][:external] = Promotion.where(
            type: 'PM', external_staff: true, year: year).count
          @@promotion_totals[year][:pm][:internal] = Promotion.where(
            type: 'PM', external_staff: false, year: year).count
          @@promotion_totals[year][:pts][:external] = Promotion.where(
            type: 'PTS', external_staff: true, year: year).count
          @@promotion_totals[year][:pts][:internal] = Promotion.where(
            type: 'PTS', external_staff: false, year: year).count
        end

        @@promotion_totals
      end
    end
  end
end