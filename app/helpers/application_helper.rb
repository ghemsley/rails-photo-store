require 'base64'
module ApplicationHelper

  def signed_in?
    return true if session[:current_user_id] && @user

    false
  end

  def admin_signed_in?
    return true if session[:current_admin_id] && @admin

    false
  end
end
