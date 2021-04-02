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
    user = User.find_by_id(session[:current_user_id]) if session[:current_user_id]
    session.delete(:current_user_id) if user
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
    timestamp = (Time.current + 1.hours).to_i
    user = get_user_if_signed_in
    if user
      res = helpers.foxycart_api_request
      case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        data = JSON.parse(res.body)
        res = helpers.foxycart_api_request(url: data['_links']['fx:store']['href'])
        case res
        when Net::HTTPSuccess, Net::HTTPRedirection
          data = JSON.parse(res.body)
          res = helpers.foxycart_api_request(url: data['_links']['fx:customers']['href'])
          case res
          when Net::HTTPSuccess, NET::HTTPRedirection
            customer_data = JSON.parse(res.body)
            customer_list = customer_data['_embedded']['fx:customers']
            customer = customer_list.find do |c|
              c['id'] == user&.uuid.to_i && ( c['is_anonymous'] ==  0  ||
                                              c['is_anonymous'] == '0' ||
                                              c['is_anonymous'] == false )
            end
            if customer
              customer_id = customer['id']
              puts "Found customer #{customer['id']} matching user #{user.id} for email #{user.email}"
              redirect_to "https://ghemsleyphotos.foxycart.com/checkout?fc_auth_token=#{fc_auth_token(customer_id, timestamp)}&fcsid=#{params[:fcsid]}&fc_customer_id=#{customer_id}&timestamp=#{timestamp}"
            else
              puts "Failed to find Foxycart customer for user #{user.id}, creating..."
              request_data = { 'email' => user.email, 'password_hash' => user.read_attribute(:password_digest) }
              res = helpers.foxycart_api_request(url: data['_links']['fx:customers']['href'],
                                                 method: 'post',
                                                 request_data: request_data)
              case res
              when Net::HTTPSuccess, Net::HTTPRedirection
                puts "Created new FoxyCart customer for user #{user.id}"
                data = JSON.parse(res.body)
                res = helpers.foxycart_api_request(url: data['_links']['self']['href'])
                case res
                when Net::HTTPSuccess, Net::HTTPRedirection
                  data = JSON.parse(res.body)
                  if user.update(uuid: data['id'])
                    puts "Updated user #{user.id} with customer info from FoxyCart"
                    customer_id = data['id']
                    redirect_to "https://ghemsleyphotos.foxycart.com/checkout?fc_auth_token=#{fc_auth_token(customer_id, timestamp)}&fcsid=#{params[:fcsid]}&fc_customer_id=#{customer_id}&timestamp=#{timestamp}"
                  else
                    puts "Error: failed to save user #{user.id}"
                    flash[:error] = "Failed to save user #{user.id}"
                    redirect_to signin_form_path
                  end
                else
                  pp res.value
                end
              else
                pp res.value
              end
            end
          else
            pp res.value
          end
        else
          pp res.value
        end
      else
        pp res.value
      end
    else
      flash[:error] = 'Error: failed to find existing user'
      redirect_to signin_form_path
    end
  end

  private

  def fc_auth_token(customer_id, timestamp)
    foxycart_secret_key = Rails.application.credentials.foxycart_secret_key
    Digest::SHA1.hexdigest("#{customer_id}|#{timestamp}|#{foxycart_secret_key}")
  end

  def session_params(*args)
    params.require(:user).permit(*args)
  end
end
