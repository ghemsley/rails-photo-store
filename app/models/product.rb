class Product < ApplicationRecord
  # Relations
  has_many :dimensions, dependent: :destroy
  accepts_nested_attributes_for :dimensions

  has_many :price_modifiers, through: :dimensions, dependent: :destroy
  accepts_nested_attributes_for :price_modifiers

  has_many :quantities
  has_many :users, through: :quantities

  has_one_attached :image, dependent: :destroy do |image|
    image.variant(:thumbnail, resize_to_limit: [640, 640])
    image.variant(:thumbnail_medium, resize_to_limit: [1080, 1080])
  end

  belongs_to :category, optional: false

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { minimum: 1, maximum: 255, too_short: 'Please enter a name',
                                                                                    too_long: '%{count} characters is the maximum allowed' }
  validates :description, presence: true,
                          length: { minimum: 1, maximum: 1024, too_short: 'Please enter a description',
                                    too_long: '%{count} characters is the maximum allowed' }
  validates :tags, length: { minimum: 0, maximum: 1024, too_long: '%{count} characters is the maximum allowed' }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :price_unit, presence: true, inclusion: { in: %w[usd Usd USD],
                                                      message: '%{value} is not a valid unit, currently only USD is supported' }
  validates_associated :dimensions

  # Scopes
  scope :price_over, ->(price) { where('price > ?', price) }
  scope :price_under, ->(price) { where('price < ?', price) }
  scope :price_unit_is, lambda { |unit|
                          where(price_unit: unit.strip)
                            .or(where(price_unit: unit.strip.upcase))
                            .or(where(price_unit: unit.strip.downcase))
                        }
  scope :length_over, ->(length) { joins(:dimensions).where('length > ?', length) }
  scope :length_under, ->(length) { joins(:dimensions).where('length < ?', length) }
  scope :width_over, ->(width) { joins(:dimensions).where('width > ?', width) }
  scope :width_under, ->(width) { joins(:dimensions).where('width < ?', width) }
  scope :height_over, ->(height) { joins(:dimensions).where('height > ?', height) }
  scope :height_under, ->(height) { joins(:dimensions).where('height < ?', height) }
  scope :distance_unit_is, lambda { |unit|
                             joins(:dimensions).where('distance_unit = ?', unit.strip)
                                               .or(where('distance_unit = ?', unit.strip.upcase))
                                               .or(where('distance_unit = ?', unit.strip.downcase))
                           }

  scope :weight_over, ->(weight) { joins(:dimensions).where('weight > ?', weight) }
  scope :weight_under, ->(weight) { joins(:dimensions).where('weight < ?', weight) }
  scope :weight_unit_is, lambda { |unit|
                           joins(:dimensions).where('weight_unit = ?', unit.strip)
                                             .or(where('weight_unit = ?', unit.strip.upcase))
                                             .or(where('weight_unit = ?', unit.strip.downcase))
                         }
  scope :name_contains, ->(string) { where('name LIKE ?', "%#{string}%") }
  scope :description_contains, ->(string) { where('description LIKE ?', "%#{string}%") }
  scope :tags_contains, ->(string) { where('tags LIKE ?', "%#{string}%") }
  scope :metadata_contains, lambda { |string|
                              name_contains(string)
                                .or(description_contains(string))
                                .or(tags_contains(string.strip))
                            }

  # Class methods
  def self.filter_metadata(query, filters)
    search = metadata_contains(query)
    filters.each do |param_name, param_value|
      search = search.send(param_name, param_value) if param_value.present?
    end
    search
  end

  def self.most_popular
    Product.joins(:quantities).order('amount DESC').group(:product_id).sum(:amount).collect do |product_id, amount|
      {product: Product.find(product_id), amount: amount}
    end.sort do |a, b|
      a[:amount] <=> b[:amount]
    end.reverse
  end

  # Instance methods
  def tags_to_a
    tags.downcase.strip.split
  end

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
