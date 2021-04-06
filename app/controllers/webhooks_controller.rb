class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def foxycart_webhook
    data = ActiveSupport::JSON.decode(request.body.read)
    if (data['_embedded']['fx:customer']['is_anonymous'] ==  0  ||
        data['_embedded']['fx:customer']['is_anonymous'] == '0' ||
        data['_embedded']['fx:customer']['is_anonymous'] == false)
      user = User.find_or_initialize_by(uuid: data['_embedded']['fx:customer']['id'].to_s)
      user.email = data['_embedded']['fx:customer']['email']
      user.password_digest = data['_embedded']['fx:customer']['password_hash']
      render status: :internal_server_error, json: user.errors.full_messages.to_json and return unless user.save

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
          render status: :ok, json: "Saved new quantity #{quantity.id} for user #{user.id} and product #{product.id} with amount #{quantity.amount}".to_json
        else
          render status: :internal_server_error, json: quantity.errors.full_messages.to_json
        end
      end
    end
  end
end
