require 'spec_helper'

describe ServicesController do
  include CfConnectionHelper

  context 'without a user logged in' do
    use_vcr_cassette "controllers/no_logged/services", :record => :new_episodes

    describe 'GET index' do
      it 'redirects to login page' do
        get :index
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/login")
      end
    end

    describe 'POST create' do
      it 'redirects to login page' do
        post :create, :name => "fakeservice", :ss => "redis"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/login")
      end
    end

    describe 'DELETE delete' do
      it 'redirects to login page' do
        delete :delete, :name => "fakeservice"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/login")
      end
    end
  end

  context 'with a user logged in' do
    before(:each) do
      cloudfoundry_set_user_cookies(CloudFoundry::Client::DEFAULT_TARGET)
    end

    use_vcr_cassette "controllers/logged/services", :record => :new_episodes

    describe 'GET index' do
      it 'renders index page' do
        get :index
        response.code.should eq("200")
        response.should render_template("index")
      end

      it 'assigns services info as @services and @available_system_services' do
        get :index
        assigns(:services).should_not be_nil
        assigns(:available_system_services).should_not be_nil
        assigns(:available_system_services).should_not be_empty
      end

      it 'renders index page with a flash alert when a server error occurs' do
        VCR.use_cassette("controllers/logged/services_index_error", :record => :new_episodes, :exclusive => true) do
          get :index
          response.code.should eq("200")
          response.should render_template("index")
          flash[:alert].should_not be_empty
        end
      end
    end

    describe 'POST create' do
      it 'redirects to services page with a flash alert when service name is blank' do
        post :create, :name => "", :ss => "redis"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/services")
        flash[:alert].should include(I18n.t('services.controller.name_blank'))
      end

      it 'redirects to services page with a flash alert when system service is blank' do
        post :create, :name => "fakeservice", :ss => ""
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/services")
        flash[:alert].should include(I18n.t('services.controller.service_blank'))
      end

      it 'redirects to services page with a flash notice when service is created' do
        post :create, :name => "fakeservice", :ss => "redis"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/services")
        flash[:notice].should include(I18n.t('services.controller.service_created', :name => "fakeservice"))
      end

      it 'assigns service info as @new_service when service is created' do
        post :create, :name => "fakeservice", :ss => "redis"
        assigns(:new_service).should_not be_nil
        assigns(:new_service).first[:name].should include("fakeservice")
      end

      it 'redirects to services page with a flash alert when service name already exists' do
        VCR.use_cassette("controllers/logged/services_already_exists", :record => :new_episodes, :exclusive => true) do
          post :create, :name => "fakeservice", :ss => "redis"
          response.code.should eq("302")
          response.should redirect_to("/" + I18n.locale.to_s + "/services")
          flash[:alert].should include(I18n.t('services.controller.already_exists'))
        end
      end

      it 'redirects to services page with a flash alert when a server error occurs' do
        VCR.use_cassette("controllers/logged/services_create_error", :record => :new_episodes, :exclusive => true) do
          post :create, :name => "fakeservice", :ss => "redis"
          response.code.should eq("302")
          response.should redirect_to("/" + I18n.locale.to_s + "/services")
          flash[:alert].should_not be_empty
        end
      end
    end

    describe 'DELETE delete' do
      it 'redirects to services page with a flash alert when service name is blank' do
        delete :delete, :name => ""
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/services")
        flash[:alert].should include(I18n.t('services.controller.name_blank'))
      end

      it 'redirects to services page with a flash notice when service is deleted' do
        delete :delete, :name => "fakeservice"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/services")
        flash[:notice].should include(I18n.t('services.controller.service_deleted', :name => "fakeservice"))
      end

      it 'redirects to services page with a flash alert when service does not exists' do
        delete :delete, :name => "noservice"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/services")
        flash[:alert].should_not be_empty
      end
    end
  end
end