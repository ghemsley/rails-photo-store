class UsersController < ApplicationController
  def index
    redirect_unless_admin_signed_in
    @users = User.all
  end

  def show
    if @admin || session[:current_user_id] == params[:id]
      @user = User.find(params[:id].to_i)
    else
      flash[:error] = 'Unauthorized'
      redirect_to root_path
    end
  end

  def new
    @user = User.new
  end

  def create
    user = User.find_or_create_by(email: params[:email])
    if user
      session[:current_user_id] = user.id
      puts user
    end
  end

  def edit
    if @admin || session[:current_user_id] == params[:id]
      @user = User.find(params[:id].to_i)
    else
      redirect_to root_path
    end
  end

  def update
    admin = get_admin_if_signed_in
    if admin
      user = User.find(params[:user][:id].to_i)
      params[:user].each do |param_name, _param_value|
        user.update(user_params(param_name))
      end
      flash[:notice] = "Updated user #{user.id}"
      redirect_to user_path(user)
    elsif session[:current_user_id] == params[:user][:id]
      user = User.find(params[:user][:id].to_i)
      user.update(user_params(params[:user]))
      redirect_to user_path(user)
    else
      flash[:error] = 'Failed to update user'
      redirect_to edit_user_path(session[:current_user_id])
    end
  end

  def destroy
    if session[:current_user_id] == params[:id]
      user = User.find(params[:id].to_i)
      session.delete[:current_user_id] if session[:current_user_id] == user.id
      if user.destroy
        flash[:notice] = "Destroyed user #{params[:id]}"
        redirect_to root_path
      else
        flash[:error] = 'Failed to destroy user'
        redirect_to user_path(user)
      end
    else
      flash[:error] = 'Unauthorized'
      redirect_to root_path
    end
  end

  private

  def user_params(*args)
    params.require(:user).permit(*args)
  end
end
