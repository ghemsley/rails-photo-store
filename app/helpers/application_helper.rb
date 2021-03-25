require 'base64'
module ApplicationHelper
  def snipcart_api_url
    'https://app.snipcart.com/api'.freeze
  end

  def snipcart_api_key
    'NTk1ZTVlYjktNmM4OS00NTkzLWJiZTMtZDIxYTY4MzQxNjAzNjM3NTE2NDc0NDg3NDY5Njcz'.freeze
  end

  def snipcart_private_api_key
    ENV['SNIPCART_PRIVATE_API_KEY']
  end

  def snipcart_private_api_key_base64
    Base64.strict_encode64("#{snipcart_private_api_key}:").to_s.freeze
  end

  def admin_secret
    ENV['RAILS_ADMIN_SECRET']
  end

  def signed_in?
    return true if session[:current_user_id] && @user

    false
  end

  def admin_signed_in?
    return true if session[:current_admin_id] && @admin

    false
  end
end
