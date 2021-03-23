class Discount < ApplicationRecord
  belongs_to :user
  belongs_to :order, optional: true

  def amount
    order.cart.subtotal * (percentage / 100)
  end

  def exhausted
    times_applied >= max_applications
  end
end
