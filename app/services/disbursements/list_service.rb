module Disbursements
  class ListService
    def initialize(params)
      @params = params
    end

    def call
      scope = Disbursement.where(year: @params[:year], week: @params[:week])
      scope = scope.where(merchant_id: @params[:merchant_id]) if @params.key?(:merchant_id)
      scope
    end
  end
end
