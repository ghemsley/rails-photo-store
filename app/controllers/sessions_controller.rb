class SessionsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    user = User.find_by(email: params[:user][:email]) if params[:user][:email]
    if user&.authenticate(params[:user][:password])
      session[:current_user_id] = user.id
      flash[:notice] = 'Signed in'
      redirect_to user_path(user)
    else
      flash[:error] = 'Failed to sign in'
      redirect_to signin_form_path
    end
  end

  def destroy
    session.delete(:current_user_id) if session[:current_user_id]
    flash[:notice] = "Signed out"
    redirect_to root_path
  end

  def admin_create
    admin = Admin.find_by_username(params[:admin][:username])
    if admin.authenticate(params[:admin][:password])
      session[:current_admin_id] = admin.id
      redirect_to admin_path(admin)
    else
      redirect_to admin_signin_form_path
    end
  end

  def admin_destroy
    session.delete(:current_admin_id) if session[:current_admin_id]
    flash[:notice] = 'Signed out'
    redirect_to root_url
  end

  def sso_redirect
    redirect_to signin_form_path and return unless params[:fcsid]
    sso_redirect_foxycart_auth(params)
  end

  def reverse_sso_redirect
    redirect_to root_path and return unless params[:fc_auth_token] && params[:timestamp] && params[:fc_customer_id]
    reverse_sso_redirect_foxycart_auth(params)
  end

  private

  def fc_auth_token(customer_id, timestamp)
    foxycart_secret_key = Rails.application.credentials.foxycart_secret_key
    Digest::SHA1.hexdigest("#{customer_id}|#{timestamp}|#{foxycart_secret_key}")
  end

  def sso_redirect_foxycart_auth(params)
    timestamp = (Time.current + 1.hours).to_i
    user = get_user_if_signed_in
    if user
      foxycart_data = get_foxycart_data
      customer_list = foxycart_data[:customer_list]
      customer = customer_list.find do |c|
        c['id']&.to_i == user&.uuid.to_i && ( c['is_anonymous'] ==  0  ||
                                              c['is_anonymous'] == '0' ||
                                              c['is_anonymous'] == false )
      end
      if customer
        customer_id = customer['id']
        logger.info "Found customer #{customer_id} matching user #{user.id}"
        redirect_to "https://ghemsleyphotos.foxycart.com/checkout?fc_auth_token=#{fc_auth_token(customer_id, timestamp)}&fcsid=#{params[:fcsid]}&fc_customer_id=#{customer_id}&timestamp=#{timestamp}"
      else
        logger.info "Failed to find Foxycart customer for user #{user.id}, creating..."
        request_data = { 'email' => user.email, 'password_hash' => user.read_attribute(:password_digest) }
        res = foxycart_api_request( url: foxycart_data[:store_data]['_links']['fx:customers']['href'],
                                    method: 'post',
                                    request_data: request_data )
        case res
        when Net::HTTPSuccess, Net::HTTPRedirection
          logger.info "Created new FoxyCart customer for user #{user.id}"
          data = JSON.parse(res.body)
          res = foxycart_api_request(url: data['_links']['self']['href'])
          case res
          when Net::HTTPSuccess, Net::HTTPRedirection
            data = JSON.parse(res.body)
            if user.update(uuid: data['id'])
              logger.info "Updated user #{user.id} with customer info from FoxyCart"
              customer_id = data['id']
              redirect_to "https://ghemsleyphotos.foxycart.com/checkout?fc_auth_token=#{fc_auth_token(customer_id, timestamp)}&fcsid=#{params[:fcsid]}&fc_customer_id=#{customer_id}&timestamp=#{timestamp}"
            else
              logger.error "Failed to save user #{user.id}"
              flash[:error] = "Failed to save user #{user.id}"
              redirect_to root_path
            end
          else
            logger.error "#{res.value}: Failed to get customer info from FoxyCart"
            redirect_to root_path
          end
        else
          logger.error "#{res.value}: Failed to create new customer for user #{user.id}"
          redirect_to root_path
        end
      end
    else
      redirect_to "https://ghemsleyphotos.foxycart.com/checkout?fc_auth_token=#{fc_auth_token(0, timestamp)}&fcsid=#{params[:fcsid]}&fc_customer_id=#{0}&timestamp=#{timestamp}"
    end
  end

  def reverse_sso_redirect_foxycart_auth(params)
    remote_fc_auth_token = params[:fc_auth_token]
    remote_timestamp = params[:timestamp]
    fc_customer_id = params[:fc_customer_id]
    local_timestamp = (Time.current).to_i
    if remote_timestamp.to_i > local_timestamp && remote_fc_auth_token == fc_auth_token(fc_customer_id, remote_timestamp.to_i)
      customer_list = get_foxycart_data[:customer_list]
      customer = customer_list.find do |c|
        c['id'] == fc_customer_id.to_i && ( c['is_anonymous'] ==  0  ||
                                            c['is_anonymous'] == '0' ||
                                            c['is_anonymous'] == false )
      end
      if customer
        user = User.find_or_initialize_by(uuid: fc_customer_id)
        user.email = customer['email']
        user.password_digest = customer['password_hash']
        if user.save
          session[:current_user_id] = user.id
          flash[:notice] = "Signed in user #{user.email}"
          redirect_to user_path(user)
        else
          flash[:error] = "Failed to create new user account"
          redirect_to root_path
        end
      else
        flash[:error] = "Failed to find FoxyCart customer matching id #{fc_customer_id}"
        redirect_to root_path
      end
    else
      flash[:error] = "Failed to verify authorization token"
      redirect_to root_path
    end
  end
end
