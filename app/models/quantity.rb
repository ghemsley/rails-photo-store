class Quantity < ApplicationRecord
  belongs_to :product
  belongs_to :user

  scope :has_been_purchased, -> { where("amount > 0") }
  scope :order_by_amount, -> {order(amount: :desc)}
end
