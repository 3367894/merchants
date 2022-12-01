class Shopper < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
  validates :nif, presence: true
end
