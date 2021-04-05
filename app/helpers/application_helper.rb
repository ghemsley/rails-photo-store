require 'base64'
module ApplicationHelper
  def admin_secret
    Rails.application.credentials.rails_admin_secret
  end

  def signed_in?
    return true if session[:current_user_id] && @user

    false
  end

  def admin_signed_in?
    return true if session[:current_admin_id] && @admin

    false
  end
end
