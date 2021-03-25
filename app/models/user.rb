class User < ApplicationRecord
  has_many :quantities
  has_many :products, through: :quantities
  has_many :orders
  has_many :discounts
  has_one :address
  has_one :cart

  validates :email, uniqueness: true
  validates :uuid, uniqueness: true
end
