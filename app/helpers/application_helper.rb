require 'base64'
module ApplicationHelper
  def admin_secret
    Rails.application.credentials.rails_admin_secret
  end

  def signed_in?
    return true if session[:current_user_id] && @user

    false
  end

  def admin_signed_in?
    return true if session[:current_admin_id] && @admin

    false
  end

  def foxycart_api_request(url: nil, method: nil, request_data: nil, access_token: nil, refresh_token: nil)
    uri = if url
            URI(url)
          elsif refresh_token
            URI('https://api.foxycart.com/token')
          else
            URI('https://api.foxycart.com')
          end
    if !refresh_token
      case method&.downcase
      when 'get', nil
        req = Net::HTTP::Get.new(uri)
      when 'post'
        req = Net::HTTP::Post.new(uri)
      else
        pp "Warning: invalid method for API request, defaulting to 'get'"
        req = Net::HTTP::Get.new(uri)
      end
      req['Content-Type'] = 'application/hal+json'
      req['FOXY-API-VERSION'] = '1'
      req['Authorization'] = if access_token
                               "Bearer #{access_token}"
                             else
                               "Bearer #{ENV['NEW_FOXYCART_ACCESS_TOKEN'] || Rails.application.credentials.foxycart_access_token }"
                             end
      if method&.downcase == 'post'
        if request_data.respond_to?('deep_stringify_keys')
          req.set_form_data(request_data.deep_stringify_keys)
        elsif request_data
          req.set_form_data(request_data)
        end
      end
    else
      req = Net::HTTP::Post.new(uri)
      req['Content-Type'] = 'application/hal+json'
      req['FOXY-API-VERSION'] = '1'
      auth = Base64.strict_encode64("#{Rails.application.credentials.foxycart_client_id}:#{Rails.application.credentials.foxycart_client_secret}")
      req['Authorization'] = "Basic #{auth}"
      req.set_form_data('grant_type' => 'refresh_token', 'refresh_token' => refresh_token)
    end

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end

    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      if refresh_token
        data = JSON.parse(res.body)
        access_token = data['access_token']
        puts 'Making test request with refreshed token...'
        test_res = if url
                     foxycart_api_request(url: url, access_token: access_token)
                   else
                     foxycart_api_request(access_token: access_token)
                   end
        case test_res
        when Net::HTTPSuccess, Net::HTTPRedirection
          puts 'Test request successful!'
          ENV['NEW_FOXYCART_ACCESS_TOKEN'] = data['access_token'].to_s
          pp test_res
        else
          pp test_res.value
        end
      else
        pp res
      end
    when Net::HTTPUnauthorized
      puts 'Unauthorized: Refreshing token...'
      new_res = foxycart_api_request(refresh_token: Rails.application.credentials.foxycart_refresh_token)
      case new_res
      when Net::HTTPSuccess, Net::HTTPRedirection
        pp new_res
      else
        pp new_res.value
      end
    else
      pp res.value
    end
  end
end
