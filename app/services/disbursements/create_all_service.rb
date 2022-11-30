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
      while today >= current_date
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
      @merchant_ids ||= Order.pluck("distinct merchant_id")
    end

    def today
      @today ||= Date.today
    end

    def first_date
      @first_date ||= Order.where.not(completed_at: nil)
                           .order(:completed_at).first.completed_at.beginning_of_week
    end
  end
end
