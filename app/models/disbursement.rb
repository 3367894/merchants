class Disbursement < ApplicationRecord
  belongs_to :merchant

  validates :merchant_id, presence: true
  validates :year, presence: true
  validates :week, presence: true, uniqueness: { scope: %i[year merchant_id] }
  validates :amount_cents, presence: true
end
