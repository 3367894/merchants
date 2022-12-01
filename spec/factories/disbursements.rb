FactoryBot.define do
  factory :disbursement do
    amount_cents { 100_00 }
    merchant
    year { Date.today.year }
    week { Date.today.strftime("%-V").to_i }
  end
end
