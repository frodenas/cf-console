require 'spec_helper'

describe SystemController do
  include CfConnectionHelper

  context 'without a user logged in' do
    use_vcr_cassette "controllers/no_logged/system", :record => :new_episodes

    describe 'GET index' do
      it 'redirects to login page' do
        get :index
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/login")
      end
    end
  end

  context 'with a user logged in' do
    before(:each) do
      cloudfoundry_set_user_cookies(CloudFoundry::Client::DEFAULT_TARGET)
    end

    use_vcr_cassette "controllers/logged/system", :record => :new_episodes

    describe 'GET index' do
      it 'renders index page' do
        get :index
        response.code.should eq("200")
        response.should render_template("index")
      end

      it 'assigns system info as @info, @frameworks, @runtimes and @system_services' do
        get :index
        assigns(:info).should_not be_nil
        assigns(:info).should_not be_empty
        assigns(:frameworks).should_not be_nil
        assigns(:frameworks).should_not be_empty
        assigns(:runtimes).should_not be_nil
        assigns(:runtimes).should_not be_empty
        assigns(:system_services).should_not be_nil
        assigns(:system_services).should_not be_empty
      end

      it 'renders index page with a flash alert when a server error occurs' do
        VCR.use_cassette("controllers/logged/system_index_error", :record => :new_episodes, :exclusive => true) do
          get :index
          response.code.should eq("200")
          response.should render_template("index")
          flash[:alert].should_not be_empty
        end
      end
    end
  end
end