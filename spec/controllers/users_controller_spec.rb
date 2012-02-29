require 'spec_helper'

describe UsersController do
  include CfConnectionHelper

  context 'without a user logged in' do
    use_vcr_cassette "controllers/no_logged/users", :record => :new_episodes

    describe 'GET index' do
      it 'redirects to login page' do
        get :index
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/login")
      end
    end

    describe 'POST create' do
      it 'redirects to login page' do
        post :create, :email => "fakeuser@vcap.me", :password => "foobar", :vpassword => "foobar"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/login")
      end
    end

    describe 'DELETE delete' do
      it 'redirects to login page' do
        delete :delete, :name => Base64.encode64("fakeuser@vcap.me")
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/login")
      end
    end
  end

  context 'with a user logged in' do
    before(:each) do
      cloudfoundry_set_user_cookies(CloudFoundry::Client::DEFAULT_TARGET)
    end

    use_vcr_cassette "controllers/logged/users", :record => :new_episodes

    describe 'GET index' do
      it 'redirects to root page with a flash alert' do
        get :index
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s)
        flash[:alert].should include(I18n.t('meta.operation_not_permitted'))
      end
    end

    describe 'POST create' do
      it 'redirects to root page with a flash alert' do
        post :create, :email => "fakeuser@vcap.me", :password => "foobar", :vpassword => "foobar"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s)
        flash[:alert].should include(I18n.t('meta.operation_not_permitted'))
      end
    end

    describe 'DELETE delete' do
      it 'redirects to root page with a flash alert' do
        delete :delete, :name => Base64.encode64("fakeuser@vcap.me")
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

    use_vcr_cassette "controllers/admin/users", :record => :new_episodes

    describe 'GET index' do
      it 'renders index page' do
        get :index
        response.code.should eq("200")
        response.should render_template("index")
      end

      it 'assigns users info as @users' do
        get :index
        assigns(:users).should_not be_nil
      end

      it 'renders index page with a flash alert when a server error occurs' do
        VCR.use_cassette("controllers/admin/users_index_error", :record => :new_episodes, :exclusive => true) do
          get :index
          response.code.should eq("200")
          response.should render_template("index")
          flash[:alert].should_not be_empty
        end
      end
    end

    describe 'POST create' do
      it 'redirects to users page with a flash alert when email is blank' do
        post :create, :email => "", :password => "foobar", :vpassword => "foobar"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/users")
        flash[:alert].should include(I18n.t('users.controller.email_blank'))
      end

      it 'redirects to users page with a flash alert when password is blank' do
        post :create, :email => "fakeuser@vcap.me", :password => "", :vpassword => "foobar"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/users")
        flash[:alert].should include(I18n.t('users.controller.password_blank'))
      end

      it 'redirects to users page with a flash alert when vpassword is blank' do
        post :create, :email => "fakeuser@vcap.me", :password => "foobar", :vpassword => ""
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/users")
        flash[:alert].should include(I18n.t('users.controller.passwords_match'))
      end

      it 'redirects to users page with a flash alert when passwords does not match' do
        post :create, :email => "fakeuser@vcap.me", :password => "foobar-1", :vpassword => "foobar-2"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/users")
        flash[:alert].should include(I18n.t('users.controller.passwords_match'))
      end

      it 'redirects to users page with a flash notice when user is created' do
        post :create, :email => "fakeuser@vcap.me", :password => "foobar", :vpassword => "foobar"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/users")
        flash[:notice].should include(I18n.t('users.controller.user_created', :email =>"fakeuser@vcap.me"))
      end

      it 'assigns user info as @new_user when user is created' do
        post :create, :email => "fakeuser@vcap.me", :password => "foobar", :vpassword => "foobar"
        assigns(:new_user).should_not be_nil
        assigns(:new_user).first[:email].should include("fakeuser@vcap.me")
      end

      it 'redirects to users page with a flash alert when user already exists' do
        VCR.use_cassette("controllers/admin/users_already_exists", :record => :new_episodes, :exclusive => true) do
          post :create, :email => "fakeuser@vcap.me", :password => "foobar", :vpassword => "foobar"
          response.code.should eq("302")
          response.should redirect_to("/" + I18n.locale.to_s + "/users")
          flash[:alert].should include(I18n.t('users.controller.already_exists'))
        end
      end

      it 'redirects to users page with a flash alert when a server error occurs' do
        VCR.use_cassette("controllers/admin/users_create_error", :record => :new_episodes, :exclusive => true) do
          post :create, :email => "fakeuser@vcap.me", :password => "foobar", :vpassword => "foobar"
          response.code.should eq("302")
          response.should redirect_to("/" + I18n.locale.to_s + "/users")
          flash[:alert].should_not be_empty
        end
      end
    end

    describe 'DELETE delete' do
      it 'redirects to users page with a flash alert when email is blank' do
        delete :delete, :name => ""
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/users")
        flash[:alert].should include(I18n.t('users.controller.email_blank'))
      end

      it 'redirects to users page with a flash notice when user is deleted' do
        delete :delete, :name => Base64.encode64("fakeuser@vcap.me")
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/users")
        flash[:notice].should include(I18n.t('users.controller.user_deleted', :email => "fakeuser@vcap.me"))
      end

      it 'redirects to users page with a flash notice when user does not exists' do
        delete :delete, :name => Base64.encode64("nouser@vcap.me")
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/users")
        flash[:alert].should_not be_empty
      end
    end
  end
end