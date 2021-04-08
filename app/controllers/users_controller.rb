class UsersController < ApplicationController
  def index
    redirect_unless_admin_signed_in
    @users = User.all
  end

  def show
    if @admin
      @user = User.find(params[:id].to_i)
      @products = @user.recent_orders
    else
      @user = redirect_unless_signed_in
      if @user&.id == params[:id].to_i
        @products = @user.recent_orders
      end
    end
  end

  def new
    @user = User.new
  end

  def create
    create_user_with_foxycart(params)
  end

  def edit
    if @admin
      @user = User.find(params[:id].to_i)
    else
      redirect_unless_signed_in
    end
  end

  def update
    admin = get_admin_if_signed_in
    if admin
      user = User.find(params[:id].to_i)
      if user.update(params[:user])
        update_user_with_foxycart(user)
      else
        render :edit
      end
    else
      user = User.find(params[:id].to_i)
      if user&.authenticate(params[:user][:password])
        user.password = params[:user][:new_password] if params[:user][:new_password]
        params[:user].each do |param_name, _param_value|
          user.update(params[param_name]) unless %w[password new_password].include?(param_name.to_s)
        end
        if user.errors.any?
          flash[:error] = "Error when updating user info"
          redirect_to edit_user_path(user)
        else
          update_user_with_foxycart(user)
        end
      else
        render :edit
      end
    end
  end

  def destroy
    admin = get_admin_if_signed_in
    user = User.find(params[:id].to_i)
    session.delete[:current_user_id] if session[:current_user_id] == user.id || admin
    if user.destroy
      flash[:notice] = "Destroyed user #{params[:id]}"
      redirect_to root_path
    else
      flash[:error] = 'Failed to destroy user'
      redirect_to user_path(user)
    end
  end

  private

  def user_params(*args)
    params.require(:user).permit(*args)
  end

  def create_user_with_foxycart(params)
    user = User.find_or_initialize_by(email: params[:user][:email])
    if user && !user.uuid
      customer_list = get_foxycart_data[:customer_list]
      if customer_list
        customer = customer_list.find do |c|
          c['email'] == user&.email && (c['is_anonymous'] ==  0  ||
                                        c['is_anonymous'] == '0' ||
                                        c['is_anonymous'] == false)
        end
        if customer
          logger.info "Found customer #{customer['id']} matching user #{user.id} for email #{user.email}"
          if user.update(uuid: customer['id'],
                         password_digest: customer['password_hash'])
            flash[:notice] = "Found existing customer with local user id #{user.id}"
          else
            flash[:error] = "Found existing customer but failed to update attributes for user #{user.id}"
          end
          redirect_to user_path(user)
        elsif user.update(password: params[:user][:password],
                          password_confirmation: params[:user][:password_confirmation])
          create_foxycart_customer_for_user(user)
        else
          flash[:error] = "Failed to find FoxyCart customer or save new user attributes"
          redirect_to new_user_path
        end
      else
        flash[:error] = "Failed to get FoxyCart customer list"
        redirect_to new_user_path
      end
    elsif user
      flash[:error] = 'User with this info has aleady been created'
      redirect_to new_user_path
    else
      flash[:error] = 'Error: failed to create new user'
      redirect_to new_user_path
    end
  end

  def create_foxycart_customer_for_user(user)
    store_data = get_foxycart_data[:store_data]
    request_data = { 'email' => user.email, 'password_hash' => user.read_attribute(:password_digest) }
    res = foxycart_api_request(url: store_data['_links']['fx:customers']['href'],
                               method: 'post',
                               request_data: request_data)
    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      logger.info "Created new FoxyCart customer for user #{user.id}"
      customer_creation_data = JSON.parse(res.body)
      res = foxycart_api_request(url: customer_creation_data['_links']['self']['href'])
      case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        customer_data = JSON.parse(res.body)
        if user.update(uuid: customer_data['id'])
          logger.info "Updated user #{user.id} with customer info from FoxyCart"
          flash[:notice] = "Sucessfully created new user"
          session[:current_user_id] = user.id
          redirect_to user_path(user)
        else
          flash[:error] = "Error: failed to save uuid for user #{user.id}"
          redirect_to user_path(user)
        end
      else
        error_string = "#{res.value}: Failed to fetch customer id for user #{user.id}"
        logger.error error_string
        flash[:error] = error_string
        redirect_to user_path(user)
      end
    else
      error_string = "#{res.value}: Failed to create FoxyCart customer for user #{user.id}"
      logger.error error_string
      flash[:error] = error_string
      redirect_to user_path(user)
    end
  end

  def update_user_with_foxycart(user)
    customer_list = get_foxycart_data[:customer_list]
    if customer_list
      customer = customer_list.find do |c| 
        c['id']&.to_i == user&.uuid.to_i && ( c['is_anonymous'] ==  0  ||
                                              c['is_anonymous'] == '0' ||
                                              c['is_anonymous'] == false )
      end
      if customer
        logger.info "Found customer #{customer['id']} matching user #{user.id}"
        request_data = { 'email' => user.email, 'password_hash' => user.read_attribute(:password_digest) }
        res = foxycart_api_request(url: "https://api.foxycart.com/customers/#{customer['id']}",
                                   method: 'patch',
                                   request_data: request_data)
        case res
        when Net::HTTPSuccess, Net::HTTPRedirection
          logger.info "Updated FoxyCart customer #{user.uuid} for user #{user.id}"
          flash[:notice] = "Updated user with id #{user.id} and FoxyCart customer with id #{user.uuid}"
          redirect_to user_path(user)
        else
          logger.error "Failed to update FoxyCart customer"
          logger.error res.value
          redirect_to edit_user_path(user)
        end
      else
        flash[:error] = "Failed to find FoxyCart customer for uuid #{user.uuid}"
        redirect_to edit_user_path(user)
      end
    else
      flash[:error] = "Failed to fetch FoxyCart customer list"
      redirect_to edit_user_path(user)
    end
  end
end
