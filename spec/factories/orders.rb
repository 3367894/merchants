FactoryBot.define do
  factory :order do
    amount_cents { 100_00 }
    merchant
    shopper
    completed_at { Time.current }
  end
end
