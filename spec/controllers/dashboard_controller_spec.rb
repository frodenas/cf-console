require 'spec_helper'

describe DashboardController do
  include CfConnectionHelper

  context "without a user logged in" do
    use_vcr_cassette "controllers/no_logged/dashboard", :record => :new_episodes

    describe "GET index" do
      it "redirects to login page" do
        get :index
        response.should redirect_to("/" + I18n.locale.to_s + "/login")
      end
    end
  end

  context "with a user logged in" do
    before(:each) do
      cloudfoundry_set_user_cookies(CloudFoundry::Client::DEFAULT_TARGET)
    end

    use_vcr_cassette "controllers/logged/dashboard", :record => :new_episodes

    describe "GET index" do
      it "renders index page" do
        get :index
        response.code.should eq("200")
        response.should render_template("index")
      end

      it "assigns account applications summary as @account_apps_inuse, @account_apps_total and @account_apps_unused" do
        get :index
        assigns(:account_apps_inuse).should_not be_nil
        assigns(:account_apps_inuse).should be_a_kind_of(Fixnum)
        assigns(:account_apps_total).should_not be_nil
        assigns(:account_apps_total).should be_a_kind_of(Fixnum)
        assigns(:account_apps_unused).should_not be_nil
        assigns(:account_apps_unused).should be_a_kind_of(Fixnum)
      end

      it "assigns account memory summary as @account_mem_inuse, @account_mem_total and @account_mem_unused" do
        get :index
        assigns(:account_mem_inuse).should_not be_nil
        assigns(:account_mem_inuse).should be_a_kind_of(Fixnum)
        assigns(:account_mem_total).should_not be_nil
        assigns(:account_mem_total).should be_a_kind_of(Fixnum)
        assigns(:account_mem_unused).should_not be_nil
        assigns(:account_mem_unused).should be_a_kind_of(Fixnum)
      end

      it "assigns account services summary as @account_services_inuse, @account_services_total and @account_services_unused" do
        get :index
        assigns(:account_services_inuse).should_not be_nil
        assigns(:account_services_inuse).should be_a_kind_of(Fixnum)
        assigns(:account_services_total).should_not be_nil
        assigns(:account_services_total).should be_a_kind_of(Fixnum)
        assigns(:account_services_unused).should_not be_nil
        assigns(:account_services_unused).should be_a_kind_of(Fixnum)
      end

      it "assigns applications summary as @apps_state and @instances_states" do
        get :index
        assigns(:apps_states).should_not be_nil
        assigns(:apps_states).should_not be_empty
        assigns(:instances_states).should_not be_nil
        assigns(:instances_states).should_not be_empty
      end

      it "using EM and Fibers assigns applications summary as @apps_state and @instances_states" do
        EM.synchrony do
          get :index
          assigns(:apps_states).should_not be_nil
          assigns(:apps_states).should_not be_empty
          assigns(:instances_states).should_not be_nil
          assigns(:instances_states).should_not be_empty
          EM.stop
        end
      end
    end
  end
end