require 'cloudfoundry'

class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :require_login

  private

  def require_login
    begin
      @cf_client = cloudfoundry_client(cookies[:cf_target_url], cookies.signed[:cf_auth_token])
      @cf_logged_in = @cf_client.logged_in?
    rescue Exception => ex
      @cf_logged_in = false
    end
    if @cf_logged_in
      @cf_user = @cf_client.user
      @cf_target_url = @cf_client.target_url
      begin
        user = User.new(@cf_client)
        @cf_admin_user = user.is_admin?(@cf_user)
      rescue CloudFoundry::Client::Exception::Forbidden
        @cf_admin_user = false
      end
    else
      redirect_to login_url
    end
  end

  def cloudfoundry_client(cf_target_url, cf_auth_token = nil)
    cf_target_url ||= CloudFoundry::Client::DEFAULT_TARGET
    @client = CloudFoundry::Client.new({:adapter => which_faraday_adapter?, :target_url => cf_target_url, :auth_token => cf_auth_token})
  end

  def which_faraday_adapter?
    if (defined?(EM::Synchrony) && EM.reactor_running?)
      :em_synchrony
    else
      :net_http
    end
  end
end
