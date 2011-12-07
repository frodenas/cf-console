require 'spec_helper'

describe ServicesController do
  include CfConnectionHelper

  context "without a user logged in" do
    use_vcr_cassette "controllers/no_logged/services", :record => :new_episodes

    describe "GET index" do
      it "redirects to login page" do
        get :index
        response.should redirect_to("/login")
      end
    end

    describe "POST create" do
      it "redirects to login page" do
        post :create, :name => "redis-mock", :ss => "redis"
        response.should redirect_to("/login")
      end
    end

    describe "DELETE delete" do
      it "redirects to login page" do
        delete :delete, :name => "redis-mock"
        response.should redirect_to("/login")
      end
    end
  end

  context "with a user logged in" do
    before(:each) do
      cloudfoundry_set_user_cookies(CloudFoundry::Client::DEFAULT_TARGET)
    end

    use_vcr_cassette "controllers/logged/services", :record => :new_episodes

    describe "GET index" do
      it "renders index page" do
        get :index
        response.code.should eq("200")
        response.should render_template("index")
      end

      it "assigns services info as @services and @available_system_services" do
        get :index
        assigns(:services).should_not be_nil
        assigns(:services).should be_empty
        assigns(:available_system_services).should_not be_nil
        assigns(:available_system_services).should_not be_empty
      end
    end

    describe "POST create" do
      it "redirects to services page with a flash alert when service name is blank" do
        post :create, :name => "", :ss => "redis"
        flash[:alert].should_not be_empty
        response.should redirect_to("/services")
      end

      it "redirects to services page with a flash alert when system service is blank" do
        post :create, :name => "redis-mock", :ss => ""
        flash[:alert].should_not be_empty
        response.should redirect_to("/services")
      end

      it "redirects to services page with a flash notice when service is created" do
        VCR.use_cassette("controllers/logged/services_create_action", :record => :new_episodes, :exclusive => true) do
          post :create, :name => "redis-mock", :ss => "redis"
          flash[:notice].should_not be_empty
          flash[:notice].should include("redis-mock")
          response.should redirect_to("/services")
        end
      end

      it "assigns service info as @new_service when service is created" do
        VCR.use_cassette("controllers/logged/services_create_action", :record => :new_episodes, :exclusive => true) do
          post :create, :name => "redis-mock", :ss => "redis"
          assigns(:new_service).should_not be_nil
          assigns(:new_service).first[:name].should include("redis-mock")
        end
      end

      it "redirects to services page with a flash alert when service name already exists" do
        post :create, :name => "redis-mock", :ss => "redis"
        flash[:alert].should_not be_empty
        response.should redirect_to("/services")
      end
    end

    describe "DELETE delete" do
      it "redirects to services page with a flash notice when service is deleted" do
        VCR.use_cassette("controllers/logged/services_delete_action", :record => :new_episodes, :exclusive => true) do
          delete :delete, :name => "redis-mock"
          flash[:notice].should_not be_empty
          flash[:notice].should include("redis-mock")
          response.should redirect_to("/services")
        end
      end

      it "redirects to services page with a flash alert when service does not exists" do
        delete :delete, :name => "redis-mock"
        flash[:alert].should_not be_empty
        response.should redirect_to("/services")
      end
    end
  end
end