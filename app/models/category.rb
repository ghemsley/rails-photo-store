class Category < ApplicationRecord
  include Rails.application.routes.url_helpers
  has_many :products

  def slider_props_json
    array = products.collect do |product|
      {
        id: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        price_unit: product.price_unit,
        url: category_product_url(self, product),
        image: product.image.url,
        thumbnail: product.image.variant(resize_to_limit: [480, 720]).processed.url,
        thumbnail_medium: product.image.variant(resize_to_limit: [960, 1440]).processed.url,
        thumbnail_large: product.image.variant(resize_to_limit: [1440, 2160]).processed.url,
        dimensions_json: product.dimensions_json,
        lightbox: false
      }
    end
    JSON.generate(array).to_s
  end
end
