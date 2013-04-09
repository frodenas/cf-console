require 'spec_helper'

describe SessionsController do
  include CfConnectionHelper

  context 'without a user logged in' do
    use_vcr_cassette "controllers/no_logged/sessions", :record => :new_episodes

    describe 'GET new' do
      it 'renders new page' do
        get :new
        response.code.should eq("200")
        response.should render_template("new")
      end

      it 'assigns @target_url as DEFAULT_TARGET if cookie cf_target_url is not set' do
        get :new
        assigns(:target_url).should eql(CloudFoundry::Client::DEFAULT_TARGET)
      end

      it 'assigns @target_url as DEFAULT_TARGET if cookie cf_target_url is set' do
        request.cookies[:cf_target_url] = CloudFoundry::Client::DEFAULT_TARGET
        get :new
        assigns(:target_url).should eql(CloudFoundry::Client::DEFAULT_TARGET)
      end

      it 'returns a list of available CloudFoundry providers' do
        get :new
        assigns(:available_targets).should have_at_least(1).items
      end

      it 'assigns selected_target as DEFAULT_TARGET' do
        get :new
        assigns(:selected_target).should eql(CloudFoundry::Client::DEFAULT_TARGET)
      end

      it 'sets the default I18n locale when the HTTP_ACCEPT_LANGUAGE header is not set' do
        get :new
        response.cookies["cf_locale"].should eq(I18n.default_locale.to_s)
      end

      it 'sets the default I18n locale when the HTTP_ACCEPT_LANGUAGE header is not available' do
        request.env['HTTP_ACCEPT_LANGUAGE'] = "xx"
        get :new
        response.cookies["cf_locale"].should eq(I18n.default_locale.to_s)
      end

      it 'sets the I18n locale based on the HTTP_ACCEPT_LANGUAGE header' do
        request.env['HTTP_ACCEPT_LANGUAGE'] = "es,en-US,en"
        get :new
        response.cookies["cf_locale"].should eq("es")
      end

      it 'sets the I18N locale based on the highest HTTP_ACCEPT_LANGUAGE q-value' do
        request.env['HTTP_ACCEPT_LANGUAGE'] = "en-US;q=0.6,en;q=0.4,es;q=0.8"
        get :new
        response.cookies["cf_locale"].should eq("es")
      end
    end

    describe 'POST create' do
      it 'with an invalid user renders new template with a flash alert' do
        post :create, :email => "no-user@vcap.me", :password => "foobar", :remember_me => false,
             :target_url => CloudFoundry::Client::DEFAULT_TARGET,
             :cloud_service => CloudFoundry::Client::DEFAULT_TARGET
        response.code.should eq("200")
        response.should render_template("new")
        flash[:alert].should include(I18n.t('sessions.controller.login_failed'))
      end

      it 'with an invalid password renders new template with a flash alert' do
        post :create, :email => "user@vcap.me", :password => "no-password", :remember_me => false,
             :target_url => CloudFoundry::Client::DEFAULT_TARGET,
             :cloud_service => CloudFoundry::Client::DEFAULT_TARGET
        response.code.should eq("200")
        response.should render_template("new")
        flash[:alert].should include(I18n.t('sessions.controller.login_failed'))
      end

      it 'with valid credentials redirects to root url and sets proper cookies' do
        VCR.use_cassette("controllers/no_logged/sessions_create_action", :record => :new_episodes, :exclusive => true) do
          post :create, :email => "user@vcap.me", :password => "foobar", :remember_me => false,
               :target_url => CloudFoundry::Client::DEFAULT_TARGET,
               :cloud_service => CloudFoundry::Client::DEFAULT_TARGET
          response.code.should eq("302")
          response.should redirect_to("/" + I18n.locale.to_s)
          response.cookies["cf_proxy_user"].should be_nil
          response.cookies["cf_target_url"].should_not be_nil
          response.cookies["cf_auth_token"].should_not be_nil
        end
      end

      it 'with valid credentials redirects to root url and sets proper permanent cookies' do
        VCR.use_cassette("controllers/no_logged/sessions_create_action", :record => :new_episodes, :exclusive => true) do
          post :create, :email => "user@vcap.me", :password => "foobar", :remember_me => true,
               :target_url => CloudFoundry::Client::DEFAULT_TARGET,
               :cloud_service => CloudFoundry::Client::DEFAULT_TARGET
          response.code.should eq("302")
          response.should redirect_to("/" + I18n.locale.to_s)
          response.cookies["cf_proxy_user"].should be_nil
          response.cookies["cf_target_url"].should_not be_nil
          response.cookies["cf_auth_token"].should_not be_nil
        end
      end
    end

    describe 'GET destroy' do
      it 'redirects to login page' do
        get :destroy
        response.code.should eq("302")
        response.cookies["cf_proxy_user"].should be_nil
        response.should redirect_to("/" + I18n.locale.to_s + "/login")
      end
    end
  end

  context 'with a user logged in' do
    before(:each) do
      cloudfoundry_set_user_cookies(CloudFoundry::Client::DEFAULT_TARGET)
    end

    use_vcr_cassette "controllers/logged/sessions", :record => :new_episodes

    describe 'GET new' do
      it 'assigns target_url as DEFAULT_TARGET if cookie cf_target_url is not set' do
        get :new
        assigns(:target_url).should eql(CloudFoundry::Client::DEFAULT_TARGET)
      end

      it 'assigns target_url as DEFAULT_TARGET if cookie cf_target_url is set' do
        request.cookies[:cf_target_url] = CloudFoundry::Client::DEFAULT_TARGET
        get :new
        assigns(:target_url).should eql(CloudFoundry::Client::DEFAULT_TARGET)
      end

      it 'returns a list of available CloudFoundry providers' do
        get :new
        assigns(:available_targets).should have_at_least(1).items
      end

      it 'assigns selected_target as DEFAULT_TARGET' do
        get :new
        assigns(:selected_target).should eql(CloudFoundry::Client::DEFAULT_TARGET)
      end
    end

    describe 'POST create' do
      it 'with an invalid user renders new template with a flash alert' do
        post :create, :email => "no-user@vcap.me", :password => "foobar", :remember_me => false,
             :target_url => CloudFoundry::Client::DEFAULT_TARGET,
             :cloud_service => CloudFoundry::Client::DEFAULT_TARGET
        response.code.should eq("200")
        response.should render_template("new")
        flash[:alert].should include(I18n.t('sessions.controller.login_failed'))
      end

      it 'with an invalid password renders new template with a flash alert' do
        post :create, :email => "user@vcap.me", :password => "no-password", :remember_me => false,
             :target_url => CloudFoundry::Client::DEFAULT_TARGET,
             :cloud_service => CloudFoundry::Client::DEFAULT_TARGET
        response.code.should eq("200")
        response.should render_template("new")
        flash[:alert].should include(I18n.t('sessions.controller.login_failed'))
      end

      it 'with valid credentials redirects to root url and sets proper cookies' do
        VCR.use_cassette("controllers/logged/sessions_create_action", :record => :new_episodes, :exclusive => true) do
          post :create, :email => "user@vcap.me", :password => "foobar", :remember_me => false,
               :target_url => CloudFoundry::Client::DEFAULT_TARGET,
               :cloud_service => CloudFoundry::Client::DEFAULT_TARGET
          response.code.should eq("302")
          response.should redirect_to("/" + I18n.locale.to_s)
          response.cookies["cf_target_url"].should_not be_nil
          response.cookies["cf_auth_token"].should_not be_nil
        end
      end

      it 'with valid credentials redirects to root url and sets proper permanent cookies' do
        VCR.use_cassette("controllers/logged/sessions_create_action", :record => :new_episodes, :exclusive => true) do
          post :create, :email => "user@vcap.me", :password => "foobar", :remember_me => true,
               :target_url => CloudFoundry::Client::DEFAULT_TARGET,
               :cloud_service => CloudFoundry::Client::DEFAULT_TARGET
          response.code.should eq("302")
          response.should redirect_to("/" + I18n.locale.to_s)
          response.cookies["cf_target_url"].should_not be_nil
          response.cookies["cf_auth_token"].should_not be_nil
        end
      end
    end

    describe 'GET destroy' do
      it 'redirects to root url and deletes cookies' do
        get :destroy
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s)
        response.cookies["cf_auth_token"].should be_nil
      end
    end
  end
end