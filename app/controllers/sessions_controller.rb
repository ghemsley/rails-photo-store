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

  private

  def session_params(*args)
    params.require(:user).permit(*args)
  end
end
