class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :require_login

  private

  def require_login
    begin
      @cf_client = vmc_client(cookies[:vmc_target_url], cookies.signed[:vmc_auth_token])
      @cf_logged_in = @cf_client.logged_in?
    rescue Exception => ex
      @cf_logged_in = false
    end
    if @cf_logged_in
      @cf_user = @cf_client.user
      @cf_target = @cf_client.target
      begin
        user = User.new(@cf_client)
        @cf_admin_user = user.is_admin?(@cf_user)
      rescue  VMC::Client::TargetError
        @cf_admin_user = false
      end
    else
      redirect_to login_url
    end
  end

  def vmc_client(vmc_target_url, vmc_auth_token = nil)
    vmc_target_url ||= VMC::DEFAULT_TARGET
    @client = VMC::Client.new(vmc_target_url, vmc_auth_token)
  end
end
