class User < ApplicationRecord
  has_secure_password
  has_one :address
  has_one :cart
  has_many :orders
  has_many :discounts
end
