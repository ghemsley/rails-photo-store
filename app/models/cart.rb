class Cart < ApplicationRecord
  has_one :order
  has_many :quantities
  has_many :products, through: :quantities
  belongs_to :user
end
