class SessionsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    user = User.find_by_username(params[:user][:username])
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
    session.delete(:current_user_id)
    redirect_to root_url
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
    session.delete(:current_admin_id)
    redirect_to root_url
  end
end
