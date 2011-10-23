class SessionsController < ApplicationController
  skip_before_filter :require_login, :only => [:new, :create]

  def new
    if cookies[:vmc_target_url]
      @target_url = cookies[:vmc_target_url]
    else
      @target_url = VMC::DEFAULT_TARGET
    end
  end

  def create
    @email = params[:email]
    @password = params[:password]
    @target_url = params[:target_url]
    @remember_me = params[:remember_me]
    begin
      cf = vmc_client(@target_url)
      auth_token = cf.login(@email, @password)
    rescue
      auth_token = nil
    end

    if auth_token
      if @remember_me
        cookies.permanent[:vmc_target_url] = @target_url
        cookies.permanent.signed[:vmc_auth_token] = auth_token
      else
        cookies[:vmc_target_url] = @target_url
        cookies.signed[:vmc_auth_token] = auth_token
      end
      redirect_to root_url
    else
      flash.now[:alert] = "Invalid email or password"
      render "new"
    end
  end

  def destroy
    cookies.delete(:vmc_auth_token)
    redirect_to root_url
  end
end
