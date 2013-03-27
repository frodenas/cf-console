class SessionsController < ApplicationController
  skip_before_filter :require_login, :only => [:new, :create]

  def new
    if cookies[:cf_target_url]
      @target_url = cookies[:cf_target_url]
    else
      @target_url = CloudFoundry::Client::DEFAULT_TARGET
    end
    @available_targets = configatron.available_targets
    @selected_target = nil
    configatron.available_targets.each do |name, url|
      if url == @target_url
        @selected_target = url
        break
      end
    end
  end

  def create
    @email = params[:email]
    @password = params[:password]
    @cloud_service = params[:cloud_service]
    @target_args = params[:target_args]
    @target_url = params[:target_url]
    @remember_me = params[:remember_me]
    begin
      cf = cloudfoundry_client(@target_url)
      auth_token = cf.login(@email, @password)
    rescue
      auth_token = nil
    end

    if auth_token
      if @remember_me
        cookies.permanent[:cf_target_url] = @target_url
        cookies.permanent.signed[:cf_auth_token] = auth_token
      else
        cookies[:cf_target_url] = @target_url
        cookies.signed[:cf_auth_token] = auth_token
      end
      cookies.delete(:cf_proxy_user)
      redirect_to root_url
    else
      flash.now[:alert] = I18n.t('sessions.controller.login_failed')
      @available_targets = configatron.available_targets
      @selected_target = nil
      configatron.available_targets.each do |name, url|
        if url == @cloud_service
          @selected_target = url
          break
        end
      end
      render "new"
    end
  end

  def destroy
    cookies.delete(:cf_auth_token)
    cookies.delete(:cf_proxy_user)
    redirect_to root_url
  end
end
