module CfConnectionHelper
  def cloudfoundry_client(cf_target_url, auth_token = nil)
    cf_client = CloudFoundry::Client.new({:target_url => cf_target_url, :auth_token => auth_token})
  end

  def cloudfoundry_client_user_logged(cf_target_url)
    cf_client = cloudfoundry_client(cf_target_url)
    auth_token = cf_client.login("user@vcap.me", "foobar")
    cf_client
  end

  def cloudfoundry_client_admin_logged(cf_target_url)
    cf_client = cloudfoundry_client(cf_target_url)
    auth_token = cf_client.login("admin@vcap.me", "foobar")
    cf_client
  end

  def cloudfoundry_set_user_cookies(cf_target_url)
    jar = @request.cookie_jar
    jar.signed[:cf_auth_token] = "04085b084922117573657240766361702e6d65063a0645546c2b07b7fc514f2219d196b0898b1885eeae68a4b2ae77ad04a407f168"
    request.cookies[:cf_target_url] = cf_target_url
    request.cookies[:cf_auth_token] = jar[:cf_auth_token]
  end

  def cloudfoundry_set_admin_cookies(cf_target_url)
    jar = @request.cookie_jar
    jar.signed[:cf_auth_token] = "04085b0849221261646d696e40766361702e6d65063a0645546c2b07fbfc514f22198b59e9fc1452aab8b7ae85c5f0ba2a0e2cf36d75"
    request.cookies[:cf_target_url] = cf_target_url
    request.cookies[:cf_auth_token] = jar[:cf_auth_token]
  end
end