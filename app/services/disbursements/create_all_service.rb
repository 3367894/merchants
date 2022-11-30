module Disbursements
  class CreateAllService
    def initialize(date = nil)
      @date = date&.beginning_of_week
    end

    def call
      if @date
        create_for_date(@date)
      else
        create_for_all_orders
      end
    end

    private

    def create_for_all_orders
      current_date = first_date
      while last_date >= current_date
        create_for_date(current_date)
        current_date += 7.days
      end
    end

    def create_for_date(date)
      merchant_ids.each do |merchant_id|
        Disbursements::CreateService.new(merchant_id, date.year, date.strftime("%-V").to_i).call
      end
    end

    def merchant_ids
      @merchant_ids ||= Merchant.pluck("id")
    end

    def first_date
      @first_date ||= Order.where.not(completed_at: nil)
                           .order(:completed_at).first.completed_at.beginning_of_week
    end

    def last_date
      @last_date ||= Order.where.not(completed_at: nil).order(:completed_at).last.completed_at
    end
  end
end
