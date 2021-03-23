class UsersController < ApplicationController
  def index
    @admin = redirect_unless_admin_signed_in
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    user = User.new(user_params(:username, :email, :password, :password_confirmation))
    if user.save
      redirect_to user_path(user)
    else
      flash[:error] = 'Failed to create user'
      redirect_to new_user_path
    end
  end

  def edit
    @admin = get_admin_if_signed_in
    @user = User.find(params[:id].to_i)
    redirect_to root_path if (@user&.id != session[:current_user_id].to_i && !session[:current_admin_id])
  end

  def update
    admin = get_admin_if_signed_in
    if admin
      user = User.find(params[:user][:id])
      params[:user].each do |param_name, _param_value|
        user.update(user_params(param_name))
      end
      flash[:notice] = "Updated user #{user.id}"
      redirect_to user_path(user)
    else
      user = User.find(session[:current_user_id])
      if user.authenticate(params[:user][:password])
        user.password = params[:user][:new_password] if params[:user][:new_password]
        params[:user].each do |param_name, _param_value|
          user.update(user_params(param_name)) unless %w[password new_password].include?(param_name.to_s)
        end
        redirect_to user_path(user)
      else
        flash[:error] = 'Failed to save edits'
        redirect_to edit_user_path(user)
      end
    end
  end

  def destroy
    user = User.find(params[:id])
    if user.destroy
      redirect_to root_url
    else
      flash[:error] = 'Failed to destroy user'
      redirect_to user_path(user)
    end
  end

  private

  def user_params(*args)
    params.require(:user).permit(*args)
  end
end
