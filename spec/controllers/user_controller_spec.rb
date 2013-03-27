require 'spec_helper'

describe UserController do
  include CfConnectionHelper

  context 'without a user logged in' do
    use_vcr_cassette "controllers/no_logged/user", :record => :new_episodes

    describe 'GET switch' do
      it 'redirects to login page' do
        get :switch, :email => "fake@fake.com"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/login")
      end
    end
    
    describe 'GET switch_view_app' do
      it 'redirects to login page' do
        get :switch_view_app, :name => "noapp", :email => "fake@fake.com"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/login")
      end
    end
    
    describe 'GET clear' do
      it 'redirects to login page' do
        get :clear
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/login")
      end
    end
  end

  context 'with a user logged in' do
    before(:each) do
      cloudfoundry_set_user_cookies(CloudFoundry::Client::DEFAULT_TARGET)
    end
  
    use_vcr_cassette "controllers/logged/user", :record => :new_episodes

    describe 'GET switch' do
      it 'redirects to root page with a flash alert' do
        get :switch, :email => "user@vcap.me"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s)
        flash[:alert].should include(I18n.t('meta.operation_not_permitted'))
      end
    end
    
    describe 'GET switch_view_app' do
      it 'redirects to root page with a flash alert' do
        get :switch_view_app, :name => "noapp", :email => "fake@fake.com"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s)
        flash[:alert].should include(I18n.t('meta.operation_not_permitted'))
      end
    end
    
    describe 'GET clear' do
      it 'redirects to root page with a flash alert' do
        get :clear
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s)
        flash[:alert].should include(I18n.t('meta.operation_not_permitted'))
      end
    end
  end
  
  context 'with an admin user logged in' do
    before(:each) do
      cloudfoundry_set_admin_cookies(CloudFoundry::Client::DEFAULT_TARGET)
    end

    use_vcr_cassette "controllers/admin/user", :record => :new_episodes

    describe 'GET switch' do
      it 'redirects to app page' do
        get :switch, :email => "user@vcap.me"
        response.code.should eq("302")
        response.cookies["cf_proxy_user"].should == "user@vcap.me"
        response.should redirect_to("/" + I18n.locale.to_s + "/apps")
      end
    end

    describe 'GET switch_view_app' do
      it 'redirects to view the app' do
        get :switch_view_app, :name => "noapp", :email => "user@vcap.me"
        response.code.should eq("302")
        response.cookies["cf_proxy_user"].should == "user@vcap.me"
        response.should redirect_to("/" + I18n.locale.to_s + "/app/noapp")
      end
    end

    describe 'GET clear' do
      it 'redirects to apps_info_url' do
        request.cookies["cf_proxy_user"] = "user@vcap.me"
        get :clear
        response.cookies["cf_proxy_user"].should be_nil
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/apps")
      end
    end
  end
end
