class Order < ApplicationRecord
  belongs_to :shopper
  belongs_to :merchant

  validates :amount_cents, presence: true
end
