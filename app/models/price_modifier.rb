class PriceModifier < ApplicationRecord
  belongs_to :dimension, optional: false

  validates :number, numericality: { greater_than_or_equal_to: 0 }, allow_nil: false
  validates :unit, presence: true, inclusion: { in: %w[usd Usd USD],
                                                message: '%{value} is not a valid unit, currently only USD is supported' }, allow_nil: false

  def to_s
    "$#{number.round(2)} #{unit.upcase}"
  end
end
