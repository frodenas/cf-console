class UserController < ApplicationController
  before_filter :require_admin

  def switch
    @email = params[:email]
    cookies[:cf_proxy_user] = @email
    redirect_to apps_info_url
  end
  
  def clear
    cookies.delete(:cf_proxy_user)
    redirect_to apps_info_url
  end
  
  def switch_view_app
    @email = params[:email]
    @name = params[:name]
    cookies[:cf_proxy_user] = @email
    redirect_to app_info_url(@name)
  end
end
