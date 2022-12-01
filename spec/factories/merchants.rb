FactoryBot.define do
  factory :merchant do
    sequence(:email) { |n| "email#{n}@example.com" }
    name { "MerchantName" }
    cif { "MERCHANT_CIF" }
  end
end
