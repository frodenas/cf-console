module CfConnectionHelper
  def vmc_client(vmc_target_url, auth_token = nil)
    cf_client = VMC::Client.new(vmc_target_url, auth_token)
  end

  def vmc_client_user_logged(vmc_target_url)
    client = vmc_client(vmc_target_url)
    auth_token = client.login("user@vcap.me", "foobar")
    cf_client = vmc_client(vmc_target_url, auth_token)
  end

  def vmc_client_admin_logged(vmc_target_url)
    client = vmc_client(vmc_target_url)
    auth_token = client.login("admin@vcap.me", "foobar")
    cf_client = vmc_client(vmc_target_url, auth_token)
  end

  def vmc_set_user_cookies(vmc_target_url)
    jar = @request.cookie_jar
    jar.signed[:vmc_auth_token] = "04085b084922117573657240766361702e6d65063a0645546c2b079c0dbb4e2219b76dc61978db73a8263f70f1208a2cc743d5d6ba"
    request.cookies[:vmc_target_url] = vmc_target_url
    request.cookies[:vmc_auth_token] = jar[:vmc_auth_token]
  end


  def vmc_set_admin_cookies(vmc_target_url)
    jar = @request.cookie_jar
    jar.signed[:vmc_auth_token] = "04085b0849221261646d696e40766361702e6d65063a0645546c2b07a65cbc4e22192f0c48fb6684264e8245c3dadacd49dff6fe9d2b"
    request.cookies[:vmc_target_url] = vmc_target_url
    request.cookies[:vmc_auth_token] = jar[:vmc_auth_token]
  end
end