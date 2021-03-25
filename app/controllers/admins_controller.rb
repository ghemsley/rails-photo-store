class AdminsController < ApplicationController
  def index
    redirect_unless_admin_signed_in
    @admins = Admin.all
  end

  def show
    redirect_unless_admin_signed_in
  end

  def new
    @admin = Admin.new
  end

  def create
    if params[:admin][:password] == helpers.admin_secret
      admin = Admin.new(admin_params(:username, :email, :password))
      if admin.save
        flash[:notice] = 'Created new admin account'
        redirect_to admin_signin_path
      else
        flash[:error] = 'Failed to create new admin account'
        redirect_to new_admin_path
      end
    else
      flash[:error] = 'Unauthorized'
      redirect_to new_admin_path
    end
  end

  def edit
    redirect_unless_admin_signed_in
  end

  def update
    admin = Admin.find(params[:id])
    if admin.authenticate(params[:admin][:password])
      admin.password = params[:admin][:new_password] if params[:admin][:new_password]
      params[:admin].each do |param_name, _param_value|
        admin.update(admin_params(param_name)) unless %w[password new_password].include?(param_name.to_s)
      end
      redirect_to admin_path(admin)
    else
      redirect_to edit_admin_path(admin)
    end
  end

  def destroy
    admin = Admin.find(params[:id])
    if admin.destroy
      redirect_to root_url
    else
      redirect_to admin_path(admin)
    end
  end

  private

  def admin_params(*args)
    params.require(:admin).permit(*args)
  end
end
