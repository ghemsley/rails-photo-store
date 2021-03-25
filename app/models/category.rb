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
        url: category_product_path(self, product),
        image: path_for(product.image),
        thumbnail: path_for(product.image.variant(resize_to_limit: [640, 640]).processed),
        thumbnail_medium: path_for(product.image.variant(resize_to_limit: [1080, 1080]).processed),
        dimensions_json: product.dimensions_json,
        lightbox: false
      }
    end
    JSON.generate(array).to_s
  end
end
