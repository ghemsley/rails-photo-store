class Product < ApplicationRecord
  has_many :dimensions, dependent: :destroy
  accepts_nested_attributes_for :dimensions

  has_many :price_modifiers, through: :dimensions, dependent: :destroy
  accepts_nested_attributes_for :price_modifiers

  has_one_attached :image, dependent: :destroy do |image|
    image.variant :thumbnail, resize_to_limit: [640, 640]
    image.variant :thumbnail_medium, resize_to_limit: [1080, 1080]
  end

  belongs_to :quantity, optional: true
  belongs_to :category, optional: false

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { minimum: 1, maximum: 255, too_short: 'Please enter a name',
                                                                                    too_long: '%{count} characters is the maximum allowed' }
  validates :description, presence: true,
                          length: { minimum: 1, maximum: 1024, too_short: 'Please enter a description',
                                    too_long: '%{count} characters is the maximum allowed' }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :price_unit, presence: true, inclusion: { in: %w[usd Usd USD],
                                                      message: '%{value} is not a valid unit, currently only USD is supported' }
  validates_associated :dimensions

  scope :price_in_usd, -> { where(price_unit: 'usd').or(where(price_unit: 'USD')) }
  scope :price_unit, ->(unit) { where(price_unit: unit) }
  scope :price_over, ->(price) { where('price > ?', price) }
  scope :price_under, ->(price) { where('price < ?', price) }
  scope :length_over, ->(length) { joins(:dimensions).where('length > ?', length) }
  scope :length_under, ->(length) { joins(:dimensions).where('length < ?', length) }
  scope :width_over, ->(width) { joins(:dimensions).where('width > ?', width) }
  scope :width_under, ->(width) { joins(:dimensions).where('width < ?', width) }
  scope :weight_unit, ->(unit) { joins(:dimensions).where('weight_unit = ?', unit) }
  scope :weight_over, ->(weight) { joins(:dimensions).where('weight > ?', weight) }
  scope :weight_under, ->(weight) { joins(:dimensions).where('weight < ?', weight) }
  scope :name_contains, ->(string) { where('name LIKE ?', "%#{string}%") }
  scope :description_contains, ->(string) { where('description LIKE ?', "%#{string}%") }
  scope :name_or_description_contains, lambda { |string|
                                         where('name LIKE ?', "%#{string}%").or(where('description LIKE ?', "%#{string}%"))
                                       }

  def dimensions_json
    JSON.generate(dimensions.collect do |dimension|
      { price_modifier: dimension.price_modifier.number,
        length: dimension.length,
        width: dimension.width,
        height: dimension.height,
        weight: dimension.weight,
        distance_unit: dimension.distance_unit,
        weight_unit: dimension.weight_unit,
        distances_string: dimension.distances_to_s }
    end).to_s
  end
end