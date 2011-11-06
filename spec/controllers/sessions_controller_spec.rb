require 'spec_helper'

describe SessionsController do
  include CfConnectionHelper

  context "without a user logged in" do
    use_vcr_cassette "controllers/no_logged/sessions", :record => :new_episodes

    describe "GET new" do
      it "assigns target_url as DEFAULT_TARGET if cookie vmc_target_url is not set" do
        get :new
        assigns(:target_url).should eql(VMC::DEFAULT_TARGET)
      end

      it "assigns target_url as DEFAULT_LOCAL_TARGET if cookie vmc_target_url is set" do
        request.cookies[:vmc_target_url] = VMC::DEFAULT_LOCAL_TARGET
        get :new
        assigns(:target_url).should eql(VMC::DEFAULT_LOCAL_TARGET)
      end
    end

    describe "GET create" do
      it "with an invalid user renders new template with a flash alert" do
        get :create, :email => "no-user@vcap.me", :password => "foobar", :target_url => VMC::DEFAULT_LOCAL_TARGET
        flash[:alert].should_not be_empty
        response.code.should eq("200")
        response.should render_template("new")
      end

      it "with an invalid password renders new template with a flash alert" do
        get :create, :email => "user@vcap.me", :password => "no-password", :target_url => VMC::DEFAULT_LOCAL_TARGET
        flash[:alert].should_not be_empty
        response.code.should eq("200")
        response.should render_template("new")
      end

      it "with valid credentials redirects to root url and sets proper cookies" do
        VCR.use_cassette("controllers/no_logged/sessions_create_action", :record => :new_episodes, :exclusive => true) do
          get :create, :email => "user@vcap.me", :password => "foobar", :target_url => VMC::DEFAULT_LOCAL_TARGET
          response.cookies["vmc_target_url"].should_not be_nil
          response.cookies["vmc_auth_token"].should_not be_nil
          response.should redirect_to("/")
        end
      end
    end

    describe "GET destroy" do
      it "redirects to login page and deletes cookies" do
        get :destroy
        response.cookies["vmc_auth_token"].should be_nil
        response.should redirect_to("/login")
      end
    end
  end

  context "with a user logged in" do
    before(:each) do
      vmc_set_user_cookies(VMC::DEFAULT_LOCAL_TARGET)
    end

    use_vcr_cassette "controllers/logged/sessions", :record => :new_episodes

    describe "GET new" do
      it "assigns target_url as DEFAULT_LOCAL_TARGET if cookie vmc_target_url is not set" do
        get :new
        assigns(:target_url).should eql(VMC::DEFAULT_LOCAL_TARGET)
      end

      it "assigns target_url as DEFAULT_LOCAL_TARGET if cookie vmc_target_url is set" do
        request.cookies[:vmc_target_url] = VMC::DEFAULT_LOCAL_TARGET
        get :new
        assigns(:target_url).should eql(VMC::DEFAULT_LOCAL_TARGET)
      end
    end

    describe "GET create" do
      it "with an invalid user renders new template with a flash alert" do
        get :create, :email => "no-user@vcap.me", :password => "foobar", :target_url => VMC::DEFAULT_LOCAL_TARGET
        flash[:alert].should_not be_empty
        response.code.should eq("200")
        response.should render_template("new")
      end

      it "with an invalid password renders new template with a flash alert" do
        get :create, :email => "user@vcap.me", :password => "no-password", :target_url => VMC::DEFAULT_LOCAL_TARGET
        flash[:alert].should_not be_empty
        response.code.should eq("200")
        response.should render_template("new")
      end

      it "with valid credentials redirects to root url and sets proper cookies" do
        VCR.use_cassette("controllers/logged/sessions_create_action", :record => :new_episodes, :exclusive => true) do
          get :create, :email => "user@vcap.me", :password => "foobar", :target_url => VMC::DEFAULT_LOCAL_TARGET
          response.cookies["vmc_target_url"].should_not be_nil
          response.cookies["vmc_auth_token"].should_not be_nil
          response.should redirect_to("/")
        end
      end
    end

    describe "GET destroy" do
      it "redirects to root url and deletes cookies" do
        get :destroy
        response.cookies["vmc_auth_token"].should be_nil
        response.should redirect_to("/")
      end
    end
  end
end