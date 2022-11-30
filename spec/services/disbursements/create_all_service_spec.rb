require "rails_helper"

describe Disbursements::CreateAllService do
  describe "#call" do
    it "creates disbursement for order" do
      merchant = create(:merchant)
      order1 = create(:order, amount_cents: 100_00, merchant: merchant)
      create(:order, amount_cents: 200_00, merchant: merchant) # second order
      create(:order, amount_cents: 200_00, completed_at: nil, merchant: merchant) # uncompleted order

      expect { subject.call }.to change { Disbursement.count }.by(1)
      disbursement = Disbursement.last

      expect(disbursement.merchant_id).to eq(merchant.id)
      expect(disbursement.year).to eq(order1.completed_at.year)
      expect(disbursement.week).to eq(order1.completed_at.strftime("%-V").to_i)

      # 100 euro * 0.95% for amounts between 50€ - 300€ = 95 cents
      # 200 euro * 0.95% for amounts between 50€ - 300€ = 190 cents
      expect(disbursement.amount_cents).to eq(95 + 190)
    end

    it "creates separate disbursements for different weeks" do
      merchant = create(:merchant)
      order1 = create(:order, amount_cents: 100_00, merchant: merchant)
      # second order
      order2 = create(:order, amount_cents: 200_00, completed_at: 3.weeks.ago, merchant: merchant)

      expect { subject.call }.to change { Disbursement.count }.by(2)
      # for newest order - order1
      disbursement = Disbursement.last

      expect(disbursement.merchant_id).to eq(merchant.id)
      expect(disbursement.year).to eq(order1.completed_at.year)
      expect(disbursement.week).to eq(order1.completed_at.strftime("%-V").to_i)
      # 100 euro * 0.95% for amounts between 50€ - 300€ = 95 cents
      expect(disbursement.amount_cents).to eq(95)

      # for oldest order - order2
      disbursement = Disbursement.first

      expect(disbursement.merchant_id).to eq(merchant.id)
      expect(disbursement.year).to eq(order2.completed_at.year)
      expect(disbursement.week).to eq(order2.completed_at.strftime("%-V").to_i)
      # 200 euro * 0.95% for amounts between 50€ - 300€ = 190 cents
      expect(disbursement.amount_cents).to eq(190)
    end

    it "creates separate disbursements for different merchants" do
      merchant1 = create(:merchant)
      order1 = create(:order, amount_cents: 100_00, merchant: merchant1)
      merchant2 = create(:merchant)
      order2 = create(:order, amount_cents: 200_00, merchant: merchant2)

      expect { subject.call }.to change { Disbursement.count }.by(2)
      disbursement = Disbursement.first

      expect(disbursement.merchant_id).to eq(merchant1.id)
      expect(disbursement.year).to eq(order1.completed_at.year)
      expect(disbursement.week).to eq(order1.completed_at.strftime("%-V").to_i)
      # 100 euro * 0.95% for amounts between 50€ - 300€ = 95 cents
      expect(disbursement.amount_cents).to eq(95)

      disbursement = Disbursement.last

      expect(disbursement.merchant_id).to eq(merchant2.id)
      expect(disbursement.year).to eq(order2.completed_at.year)
      expect(disbursement.week).to eq(order2.completed_at.strftime("%-V").to_i)
      # 200 euro * 0.95% for amounts between 50€ - 300€ = 190 cents
      expect(disbursement.amount_cents).to eq(190)
    end

    it "create disbursement for specific week" do
      merchant = create(:merchant)
      create(:order, amount_cents: 100_00, merchant: merchant)
      # second order
      order2 = create(:order, amount_cents: 200_00, completed_at: 3.weeks.ago, merchant: merchant)

      expect { described_class.new(3.weeks.ago).call }.to change { Disbursement.count }.by(1)
      disbursement = Disbursement.last

      expect(disbursement.merchant_id).to eq(merchant.id)
      expect(disbursement.year).to eq(order2.completed_at.year)
      expect(disbursement.week).to eq(order2.completed_at.strftime("%-V").to_i)
      # 200 euro * 0.95% for amounts between 50€ - 300€ = 190 cents
      expect(disbursement.amount_cents).to eq(190)
    end
  end
end
