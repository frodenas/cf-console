require 'spec_helper'

describe AppsController do
  include CfConnectionHelper

  context "without a user logged in" do
    use_vcr_cassette "controllers/no_logged/apps", :record => :new_episodes

    describe "GET index" do
      it "redirects to login page" do
        get :index
        response.should redirect_to("/login")
      end
    end

    describe "GET show" do
      it "redirects to login page" do
        get :show, :name => "app-mock-started"
        response.should redirect_to("/login")
      end
    end

    describe "PUT stop" do
      it "redirects to login page" do
        put :stop, :name => "app-mock-started"
        response.should redirect_to("/login")
      end
    end

    describe "PUT start" do
      it "redirects to login page" do
        put :start, :name => "app-mock-started"
        response.should redirect_to("/login")
      end
    end

    describe "PUT restart" do
      it "redirects to login page" do
        put :restart, :name => "app-mock-started"
        response.should redirect_to("/login")
      end
    end

    describe "DELETE delete" do
      it "redirects to login page" do
        delete :delete, :name => "app-mock-started"
        response.should redirect_to("/login")
      end
    end

    describe "PUT set_instances" do
      it "redirects to login page" do
        put :set_instances, :name => "app-mock-started", :instances => "1"
        response.should redirect_to("/login")
      end
    end

    describe "PUT set_memsize" do
      it "redirects to login page" do
        put :set_memsize, :name => "app-mock-started", :memsize => "128"
        response.should redirect_to("/login")
      end
    end

    describe "PUT set_var" do
      it "redirects to login page" do
        put :set_var, :name => "app-mock-started", :var_name => "app-mock-started-envvar-var-mock", :var_value => "value-mock"
        response.should redirect_to("/login")
      end
    end

    describe "PUT unset_var" do
      it "redirects to login page" do
        put :unset_var, :name => "app-mock-started", :var_name => "var-mock"
        response.should redirect_to("/login")
      end
    end

    describe "PUT bind_service" do
      it "redirects to login page" do
        put :bind_service, :name => "app-mock-started", :service => "redis-mock"
        response.should redirect_to("/login")
      end
    end

    describe "PUT unbind_service" do
      it "redirects to login page" do
        put :unbind_service, :name => "app-mock-started", :service => "redis-mock"
        response.should redirect_to("/login")
      end
    end

    describe "PUT map_url" do
      it "redirects to login page" do
        put :map_url, :name => "app-mock-started", :url => "http://app-mock.vcap.me"
        response.should redirect_to("/login")
      end
    end

    describe "PUT unmap_url" do
      it "redirects to login page" do
        put :unmap_url, :name => "app-mock-started", :url => "http://app-mock.vcap.me"
        response.should redirect_to("/login")
      end
    end

    describe "GET files" do
      it "redirects to login page" do
        get :files, :name => "app-mock-started", :instance => 0, :filename => Base64.encode64("/")
        response.should redirect_to("/login")
      end
    end

    describe "GET view_file" do
      it "redirects to login page" do
        get :view_file, :name => "app-mock-started", :instance => 0, :filename => Base64.encode64("logs/stdout.log")
        response.should redirect_to("/login")
      end
    end
  end

  context "with a user logged in" do
    before(:each) do
      vmc_set_user_cookies(VMC::DEFAULT_LOCAL_TARGET)
    end

    use_vcr_cassette "controllers/logged/apps", :record => :new_episodes

    describe "GET index" do
      it "renders index page" do
        get :index
        response.code.should eq("200")
        response.should render_template("index")
      end

      it "assigns applications info as @apps" do
        get :index
        assigns(:apps).should_not be_nil
        assigns(:apps).should_not be_empty
      end
    end

    # TODO
  end
end