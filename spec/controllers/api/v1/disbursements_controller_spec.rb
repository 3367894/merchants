require "rails_helper"

describe Api::V1::DisbursementsController, type: :controller do
  describe "#index" do
    let!(:merchant) { create(:merchant) }
    let(:year) { Date.today.year }
    let(:week) { Date.today.strftime("%-V").to_i }
    let!(:disbursement) { create(:disbursement, week: week, year: year, merchant: merchant) }
    let!(:disbursement_for_another_week) { create(:disbursement, week: week + 1, year: year, merchant: merchant) }
    let!(:disbursement_for_another_merchant) { create(:disbursement, week: week, year: year) }

    context "for specific merchant" do
      it "is successful" do
        get :index, params: { merchant_id: merchant.id, year: year, week: week }
        expect(response).to be_successful
      end

      it "renders json with  disbursement data" do
        get :index, params: { merchant_id: merchant.id, year: year, week: week }

        data = JSON.parse(response.body)
        expect(data.size).to eq(1)
        disbursement_data = data.first
        expect(disbursement_data["merchant_id"]).to eq(merchant.id)
        expect(disbursement_data["year"]).to eq(year)
        expect(disbursement_data["week"]).to eq(week)
        expect(disbursement_data["amount_cents"]).to eq(100_00)
      end
    end

    context "for all merchants" do
      it "is successful" do
        get :index, params: { year: year, week: week }
        expect(response).to be_successful
      end

      it "renders json with disbursements data" do
        get :index, params: { year: year, week: week }

        data = JSON.parse(response.body)
        expect(data.size).to eq(2)
        expect(data.map { |d| d["id"] }).to match_array([disbursement.id, disbursement_for_another_merchant.id])
      end
    end

    context "without required parameters" do
      it "is not successful if doesn't have year" do
        get :index, params: { week: week }
        expect(response.status).to eq(403)
        data = JSON.parse(response.body)
        expect(data["error"]).to eq("missing year parameter")
      end

      it "is not successful if doesn't have week" do
        get :index, params: { year: year }
        expect(response.status).to eq(403)
        data = JSON.parse(response.body)
        expect(data["error"]).to eq("missing week parameter")
      end
    end
  end
end
