module Disbursements
  class CreateService
    FEE_HIGHER_300 = 0.0085
    FEE_HIGHER_50 = 0.0095
    FEE_DEFAULT = 0.01

    def initialize(merchant_id, year, week)
      @merchant_id = merchant_id
      @year = year
      @week = week
    end

    def call
      disbursement.update!(amount_cents: disbursement_amount_cents) if disbursement_amount_cents.positive?
    end

    private

    def disbursement
      Disbursement.find_or_initialize_by(merchant_id: @merchant_id, year: @year, week: @week)
    end

    def starting_date
      @starting_date ||= Date.parse("#{@year}W#{@week.to_s.rjust(2, '0')}").to_time
    end

    def orders
      Order.where(
        merchant_id: @merchant_id,
        completed_at: (starting_date..(starting_date + 6.days).end_of_day)
      )
    end

    def calc_fee(order)
      percentage = if order.amount_cents > 300_00
                     FEE_HIGHER_300
                   elsif order.amount_cents > 50_00
                     FEE_HIGHER_50
                   else
                     FEE_DEFAULT
                   end
      (order.amount_cents * percentage).to_i
    end

    def disbursement_amount_cents
      @disbursement_amount_cents ||= orders.find_each.map do |order|
        calc_fee(order)
      end.sum
    end
  end
end
