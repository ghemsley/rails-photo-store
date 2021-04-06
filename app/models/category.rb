class Category < ApplicationRecord
  include Rails.application.routes.url_helpers
  has_many :products, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { minimum: 1, maximum: 255, too_short: 'Please enter a name',
                                                                                    too_long: '%{count} characters is the maximum allowed' }
  validates :description, presence: true, length: { minimum: 1, maximum: 1024, too_short: 'Please enter a name',
                                                                               too_long: '%{count} characters is the maximum allowed' }

  def slider_props_json
    products.collect do |product|
      {
        id: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        price_unit: product.price_unit,
        url: category_product_url(self, product),
        image: url_for(product.image),
        thumbnail: url_for(product.image.variant(resize_to_limit: [480, 720]).processed),
        thumbnail_large: url_for(product.image.variant(resize_to_limit: [1440, 2160]).processed),
        dimensions_json: product.dimensions_json,
        lightbox: false
      }
    end.to_json
  end
end
