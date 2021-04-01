class WebhooksController < ApplicationController
  def foxycart_webhook
    unless request.headers['Foxy-Store-ID'] == '97720' && request.headers['Foxy-Webhook-Event'] == 'transaction/created'
      return
    end

    data = ActiveSupport::JSON.decode(request.body.read)
    uuid = data['_embedded']['fx:customer']['id'].to_s
    user = User.find_or_create_by(uuid: uuid)
    return unless user.valid?

    email = data['_embedded']['fx:customer']['email']
    user.email = email
    return unless user.save

    data['_embedded']['fx:items'].each do |item|
      product = Product.find(item['code'])
      next unless product

      quantity = Quantity.find_or_create_by(user_id: user.id, product_id: product.id)
      next unless quantity.valid?

      quantity.amount += item['quantity']
      if quantity.save
        puts "Saved new quantity #{quantity.id} for user #{user.id} and product #{product.id} with amount #{quantity.amount}"
      else
        puts quantity.errors.full_messages
      end
    end
  end
end
