class ApplicationController < ActionController::Base
  before_action :get_admin_if_signed_in, only: %i[index show new edit]

  before_action do
    ActiveStorage::Current.host = request.base_url
  end

  private

  def redirect_unless_signed_in
    if session[:current_user_id]
      user = User.find(session[:current_user_id])
      return user if user
    end

    flash[:error] = 'Unauthorized'
    redirect_to root_path
    nil
  end

  def redirect_unless_admin_signed_in
    return @admin if session[:current_admin_id] && @admin

    flash[:error] = 'Unauthorized'
    redirect_to root_path
    nil
  end

  def get_admin_if_signed_in
    if session[:current_admin_id]
      @admin = Admin.find(session[:current_admin_id])
      return @admin if @admin
    end
    nil
  end
end
