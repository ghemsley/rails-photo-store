class Order < ApplicationRecord
  has_one :cart
  has_many :quantities, through: :cart
  has_many :products, through: :quantities
  has_one :discount

  def update_total
    order_total = 0
    quantities.each do |quantity|
      order_total += quantity.product.price * quantity.number
    end
    if discount && !discount&.exhausted && !discount&.percentage&.zero? && !discount&.percentage&.nil?
      order_total -= discount.amount
      discount.times_applied += 1
      discount.save
    end
    self.total = order_total
    save
  end
end
