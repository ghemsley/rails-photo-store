class Quantity < ApplicationRecord
  has_one :product
  accepts_nested_attributes_for :product
  validates_associated :product

  belongs_to :cart
end
