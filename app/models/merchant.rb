class Merchant < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
  validates :cif, presence: true
end
