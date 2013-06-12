require 'cloudfoundry'

class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale, :require_login

  private

  def require_login
    begin
      @cf_client = cloudfoundry_client(cookies[:cf_target_url], cookies.signed[:cf_auth_token])
      @cf_logged_in = @cf_client.logged_in?
    rescue Exception
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
      if cookies[:cf_proxy_user]
        @cf_client.set_proxy_user(cookies[:cf_proxy_user])
        @cf_proxy_user = cookies[:cf_proxy_user]
      end
    else
      redirect_to login_url
    end
  end

  def require_admin
    unless @cf_admin_user
      flash[:alert] = I18n.t('meta.operation_not_permitted')
      redirect_to root_url
    end
  end

  def cloudfoundry_client(cf_target_url, cf_auth_token = nil)
    cf_target_url ||= CloudFoundry::Client::DEFAULT_TARGET
    @client = CloudFoundry::Client.new({:adapter => which_faraday_adapter?, 
                                        :target_url => cf_target_url, 
                                        :auth_token => cf_auth_token,
                                        :proxy_url => proxy_url})
  end

  def which_faraday_adapter?
    if Utils::ModuleLoaded.synchrony? && Utils::ModuleLoaded.fiberpool?
      :em_synchrony
    else
      :net_http
    end
  end

  def set_locale
    available_locales = (I18n.available_locales.collect { |lang| lang.to_s } & configatron.languages.available)
    params_locale = ([params[:locale]] & available_locales).first
    cookies_locale = ([cookies[:cf_locale]] & available_locales).first
    browser_locale = (user_agent_locale & available_locales).first
    I18n.locale = params_locale || cookies_locale || browser_locale || I18n.default_locale
    cookies.permanent[:cf_locale] = I18n.locale
  end

  def user_agent_locale
    user_agent_languages ||= request.env['HTTP_ACCEPT_LANGUAGE'].split(/\s*,\s*/).collect do |lang|
      lang += ";q=1.0" unless lang =~ /;q=\d+\.\d+$/
      lang.split(";q=")
    end.sort do |x, y|
      y.last.to_f <=> x.last.to_f
    end.collect do |lang|
      lang.first.downcase.gsub(/-[a-z]+$/i) { |x| x.upcase }
    end
  rescue
    []
  end
  
  def proxy_url
    configatron.proxy_url || ENV['https_proxy'] || ENV['HTTPS_PROXY'] || ENV['http_proxy'] || ENV['HTTP_PROXY']  
  end
end
