class User < ApplicationRecord
  has_secure_password
  has_many :quantities
  has_many :products, through: :quantities
  has_many :orders
  has_many :discounts
  has_one :address
  has_one :cart

  validates :email, uniqueness: true

  # Instance methods
  def recent_orders
    products.joins(:quantities).order('quantities.updated_at DESC').uniq
  end
end
