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
    jar.signed[:cf_auth_token] = "04085b084922117573657240766361702e6d65063a0645546c2b07eb05e54e22197d37e42a4b8e7215eba234b86b601342203c3800"
    request.cookies[:cf_target_url] = cf_target_url
    request.cookies[:cf_auth_token] = jar[:cf_auth_token]
  end

  def cloudfoundry_set_admin_cookies(cf_target_url)
    jar = @request.cookie_jar
    jar.signed[:cf_auth_token] = "04085b0849221261646d696e40766361702e6d65063a0645546c2b07b108e54e221912a91b37781faa5c88a9ffea3b0b6abd0c28983b"
    request.cookies[:cf_target_url] = cf_target_url
    request.cookies[:cf_auth_token] = jar[:cf_auth_token]
  end
end