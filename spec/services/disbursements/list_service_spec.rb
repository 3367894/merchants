require "rails_helper"

describe Disbursements::ListService do
  describe "#call" do
    let!(:merchant) { create(:merchant) }
    let(:year) { Date.today.year }
    let(:week) { Date.today.strftime("%-V").to_i }
    let!(:disbursement) { create(:disbursement, week: week, year: year, merchant: merchant) }
    let!(:disbursement_for_another_week) { create(:disbursement, week: week + 1, year: year, merchant: merchant) }
    let!(:disbursement_for_another_merchant) { create(:disbursement, week: week, year: year) }

    subject { described_class.new(params) }

    context "for specific merchant" do
      let(:params) { { merchant_id: merchant.id, week: week, year: year } }

      it "returns disbursement" do
        expect(subject.call).to eq([disbursement])
      end
    end

    context "for all merchants" do
      let(:params) { { week: week, year: year } }

      it "returns disbursement" do
        expect(subject.call).to match_array([disbursement, disbursement_for_another_merchant])
      end
    end
  end
end
