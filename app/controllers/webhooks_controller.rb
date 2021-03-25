# Source code based on example at https://docs.snipcart.com/v3/webhooks/examples
class WebhooksController < ApplicationController
  def webhook
    data = ActiveSupport::JSON.decode(request.body.read)
    case data[:eventName]
    when 'order.completed'
      user_uuid = data[:content][:user][:id]
      user = User.find_or_create_by(uuid: user_uuid)
      products = data[:content][:items].collect do |item|
        { id: Product.find(item[:id].to_i)&.id, amount: item[:quantity]&.to_i }
      end
      products.each do |product|
        quantity = Quantity.new(user_id: user&.id, product_id: product[:id], amount: product[:amount])
        if quantity.save
          puts "Saved quantity #{quantity.id}
                user_id: #{quantity.user_id}
                product_id: #{quantity.product_id}
                amount: #{quantity.amount}"
        else
          puts quantity.errors.full_messages
        end
      end
    end
  rescue StandardError
    head :bad_request
  else
    head :ok
  end
end
