FactoryBot.define do
  factory :shopper do
    sequence(:email) { |n| "email#{n}@example.com" }
    name { "ShopperName" }
    nif { "SHOPPER_NIF" }
  end
end
