class Dimension < ApplicationRecord
  belongs_to :product, optional: false

  has_one :price_modifier, dependent: :destroy
  accepts_nested_attributes_for :price_modifier

  # Validations
  validates :length, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :width, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :height, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :weight, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :distance_unit, inclusion: { in: %w[in In IN inch Inch INCH inches Inches INCHES ft Ft FT
                                                foot Foot FOOT feet Feet FEET m M meter Meter METER
                                                meters Meters METERS metre Metre METRE],
                                         message: '%{value} is not a valid unit' }, allow_blank: true
  validates :weight_unit, inclusion: { in: %w[lb Lb LB lbs Lbs LBS pounds Pounds POUNDS kg Kg KG
                                              kilograms Kilograms KILOGRAMS g G grams Grams GRAMS oz Oz
                                              ounces Ounces OUNCES],
                                       message: '%{value} is not a valid unit' }, allow_blank: true
  validates_associated :price_modifier

  def price_modifier_to_s
    return nil if price_modifier.nil?

    price_modifier.to_s
  end

  def length_to_s
    string_builder(length, distance_unit)
  end

  def width_to_s
    string_builder(width, distance_unit)
  end

  def height_to_s
    string_builder(height, distance_unit)
  end

  def weight_to_s
    string_builder(weight, weight_unit)
  end

  def distance_unit_to_s
    unit_to_s(distance_unit)
  end

  def weight_unit_to_s
    unit_to_s(weight_unit)
  end

  def distances_to_s
    string = ''
    dimensions = [length, width, height]
    dimensions.each do |dimension|
      string << "#{dimension} #{distance_unit_to_s} x " if !dimension.nil? && dimension != ''
    end
    string.chomp(' x ')
  end

  private

  def unit_to_s(unit)
    case unit.downcase
    when 'in' || 'inch' || 'inches'
      'inches'
    when 'ft' || 'foot' || 'feet'
      'feet'
    when 'cm' || 'centimeter' || 'centimetre' || 'centimeters' || 'centimetres'
      'centimeters'
    when 'm' || 'meter' || 'metre' || 'meters' || 'metres'
      'meters'
    when 'lb' || 'pound' || 'pounds' || 'lbs'
      'pounds'
    when 'kg' || 'kilogram' || 'kilograms' || 'kgs'
      'kilograms'
    when 'g' || 'gram' || 'grams'
      'grams'
    when 'oz' || 'ounce' || 'ounces'
      'ounces'
    end
  end

  def string_builder(measurement, unit)
    return nil if measurement.nil? || unit.nil?

    measurement = measurement.round(2)
    "#{measurement} #{unit_to_s(unit)}"
  end
end
