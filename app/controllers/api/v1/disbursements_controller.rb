module Api
  module V1
    class DisbursementsController < ApplicationController
      before_action :check_params

      def index
        data = Disbursements::ListService.new(permitted_params).call

        render json: data
      end

      private

      def permitted_params
        @permitted_params ||= params.permit(:merchant_id, :year, :week)
      end

      def check_params
        %i[week year].each do |required_parameter|
          unless permitted_params.include?(required_parameter)
            render(json: { error: "missing #{required_parameter} parameter" }, status: 403)
          end
        end
      end
    end
  end
end
