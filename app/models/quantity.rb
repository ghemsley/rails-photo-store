class Quantity < ApplicationRecord
  belongs_to :product
  belongs_to :user

  validates :amount, numericality: { greater_than_or_equal_to: 0 }

  scope :has_been_purchased, -> { where("amount > 0") }
  scope :order_by_amount, -> {order(amount: :desc)}
end
