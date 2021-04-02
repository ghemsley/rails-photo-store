class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def foxycart_webhook
    data = ActiveSupport::JSON.decode(request.body.read)
    uuid = data['_embedded']['fx:customer']['id'].to_s
    user = User.find_or_initialize_by(uuid: uuid)
    email = data['_embedded']['fx:customer']['email']
    user.email = email
    user.password_digest = data['_embedded']['fx:customer']['password_hash']
    return 'error' unless user.save

    data['_embedded']['fx:items'].each do |item|
      product = Product.find(item['code'])
      next unless product

      quantity = Quantity.find_or_initialize_by(user_id: user.id, product_id: product.id)
      if quantity.amount == nil
        quantity.amount = item['quantity']
      else
        quantity.amount += item['quantity']
      end
      if quantity.save
        pp "Saved new quantity #{quantity.id} for user #{user.id} and product #{product.id} with amount #{quantity.amount}"
        render status: :ok, json: @controller.to_json
      else
        pp quantity.errors.full_messages
      end
    end
  end
end
