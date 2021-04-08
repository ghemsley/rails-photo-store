class ApplicationController < ActionController::Base
  before_action :get_admin_if_signed_in, only: %i[index show new edit search popular]
  before_action :get_user_if_signed_in, only: %i[index show new edit search popular]

  before_action do
    ActiveStorage::Current.host = request.base_url
  end

  private

  def redirect_unless_signed_in
    return @user if session[:current_user_id] && @user

    flash[:error] = 'Unauthorized'
    redirect_to root_path and return
  end

  def get_user_if_signed_in
    if session[:current_user_id]
      @user = User.find(session[:current_user_id])
      return @user if @user
    end
    nil
  end

  def redirect_unless_admin_signed_in
    return @admin if session[:current_admin_id] && @admin

    flash[:error] = 'Unauthorized'
    redirect_to root_path and return
  end

  def get_admin_if_signed_in
    if session[:current_admin_id]
      @admin = Admin.find(session[:current_admin_id])
      return @admin if @admin
    end
    nil
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
      when 'patch'
        req = Net::HTTP::Patch.new(uri)
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
      if method&.downcase == 'post' || 'patch'
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

  def get_foxycart_data
    res = foxycart_api_request
    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      data = JSON.parse(res.body)
      res = foxycart_api_request(url: data['_links']['fx:store']['href'])
      case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        store_data = JSON.parse(res.body)
        res = foxycart_api_request(url: store_data['_links']['fx:customers']['href'])
        case res
        when Net::HTTPSuccess, NET::HTTPRedirection
          customer_data = JSON.parse(res.body)
          customer_list = customer_data['_embedded']['fx:customers']
          return { customer_list: customer_list, customer_data: customer_data, store_data: store_data, data: data } if customer_list
          nil
        else
          logger.error "Failed to get FoxyCart customer list"
          logger.error res.value
          return nil
        end
      else
        logger.error "Failed to get FoxyCart store info"
        logger.error res.value
        return nil
      end
    else
      logger.error "Failed to get make inital FoxyCart API request"
      logger.error res.value
      return nil
    end
  end
end
