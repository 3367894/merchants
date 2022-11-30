require "rails_helper"

describe Disbursements::CreateService do
  describe "#call" do
    let!(:merchant) { create(:merchant) }
    let(:year) { Date.today.year }
    let(:week) { Date.today.strftime("%-V").to_i }

    subject { described_class.new(merchant.id, year, week) }

    context "with orders" do
      let!(:order1) { create(:order, merchant: merchant, amount_cents: 40_00) }
      let!(:order2) { create(:order, merchant: merchant, amount_cents: 100_00) }
      let!(:order3) { create(:order, merchant: merchant, amount_cents: 500_00) }
      let!(:uncompleted_order) do
        create(:order, merchant: merchant, amount_cents: 500_00, completed_at: nil)
      end
      let!(:order_for_another_merchant) { create(:order, amount_cents: 500_00) }
      let!(:order_from_another_week) do
        create(:order, merchant: merchant, amount_cents: 500_00, completed_at: 3.weeks.ago)
      end

      it "creates disbursement for specific merchant and week" do
        expect { subject.call }.to change { Disbursement.count }.by(1)
        disbursement = Disbursement.last

        expect(disbursement.merchant_id).to eq(merchant.id)
        expect(disbursement.year).to eq(year)
        expect(disbursement.week).to eq(week)

        # 40 euro * 1% fee for amounts smaller than 50 € = 40 cents
        # 100 euro * 0.95% for amounts between 50€ - 300€ = 95 cents
        # 500 euro * 0.85% for amounts over 300€ = 425 cents
        expect(disbursement.amount_cents).to eq(40 + 95 + 425)
      end

      it "replace existing disbursement" do
        disbursement = create(:disbursement, merchant_id: merchant.id, year: year, week: week)

        expect { subject.call }.not_to(change { Disbursement.count })

        expect(disbursement.reload.merchant_id).to eq(merchant.id)
        expect(disbursement.year).to eq(year)
        expect(disbursement.week).to eq(week)

        # 40 euro * 1% fee for amounts smaller than 50 € = 40 cents
        # 100 euro * 0.95% for amounts between 50€ - 300€ = 95 cents
        # 500 euro * 0.85% for amounts over 300€ = 425 cents
        expect(disbursement.amount_cents).to eq(40 + 95 + 425)
      end

      it "works with one digit weeks number" do
        expect { described_class.new(merchant.id, year, 1).call }.not_to raise_error
      end
    end

    context "without orders" do
      it "doesn't create disbursement" do
        expect { subject.call }.not_to(change { Disbursement.count })
      end
    end
  end
end
