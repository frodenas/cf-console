require 'spec_helper'

describe AppsController do
  include CfConnectionHelper

  context 'without a user logged in' do
    use_vcr_cassette "controllers/no_logged/apps", :record => :new_episodes

    describe 'POST create' do
      it 'redirects to login page' do
        post :create, :name => "fakeapp", :instances => "1", :memsize => "64", :type => "sinatra/ruby18",
             :url => "fakeapp.vcap.me", :gitrepo => "git://github.com/frodenas/cf-sinatra-sample.git"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/login")
      end
    end

    describe 'PUT start' do
      it 'redirects to login page' do
        put :start, :name => "fakeapp"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/login")
      end
    end

    describe 'PUT set_instances' do
      it 'redirects to login page' do
        put :set_instances, :name => "fakeapp", :instances => "1"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/login")
      end
    end

    describe 'PUT set_memsize' do
      it 'redirects to login page' do
        put :set_memsize, :name => "fakeapp", :memsize => "128"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/login")
      end
    end

    describe 'PUT set_var' do
      it 'redirects to login page' do
        put :set_var, :name => "fakeapp", :var_name => "fakevar", :var_value => "fakevalue"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/login")
      end
    end

    describe 'PUT bind_service' do
      it 'redirects to login page' do
        put :bind_service, :name => "fakeapp", :service => "fakeservice"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/login")
      end
    end

    describe 'PUT map_url' do
      it 'redirects to login page' do
        put :map_url, :name => "fakeapp", :url => "http://fakeapp2.vcap.me"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/login")
      end
    end

    describe 'GET index' do
      it 'redirects to login page' do
        get :index
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/login")
      end
    end

    describe 'GET show' do
      it 'redirects to login page' do
        get :show, :name => "fakeapp"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/login")
      end
    end

    describe 'PUT unset_var' do
      it 'redirects to login page' do
        put :unset_var, :name => "fakeapp", :var_name => "fakevar"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/login")
      end
    end

    describe 'PUT unbind_service' do
      it 'redirects to login page' do
        put :unbind_service, :name => "fakeapp", :service => "fakeservice"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/login")
      end
    end

    describe 'PUT unmap_url' do
      it 'redirects to login page' do
        put :unmap_url, :name => "fakeapp", :url => "http://fakeapp2.vcap.me"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/login")
      end
    end

    describe 'PUT update_bits' do
      it 'redirects to login page' do
        put :update_bits, :name => "fakeapp", :gitrepo => "git://github.com/frodenas/cf-sinatra-sample.git"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/login")
      end
    end

    describe 'GET download_bits' do
      it 'redirects to login page' do
        get :download_bits, :name => "fakeapp"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/login")
      end
    end

    describe 'GET files' do
      it 'redirects to login page' do
        get :files, :name => "fakeapp", :instance => 0, :filename => Base64.encode64("/")
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/login")
      end
    end

    describe 'GET view_file' do
      it 'redirects to login page' do
        get :view_file, :name => "fakeapp", :instance => 0, :filename => Base64.encode64("logs/stdout.log")
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/login")
      end
    end

    describe 'PUT restart' do
      it 'redirects to login page' do
        put :restart, :name => "fakeapp"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/login")
      end
    end

    describe 'PUT stop' do
      it 'redirects to login page' do
        put :stop, :name => "fakeapp"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/login")
      end
    end

    describe 'DELETE delete' do
      it 'redirects to login page' do
        delete :delete, :name => "fakeapp"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/login")
      end
    end
  end

  context 'with a user logged in' do
    before(:all) do
      VCR.use_cassette("controllers/logged/client", :record => :new_episodes) do
        cf_client = cloudfoundry_client_user_logged(CloudFoundry::Client::DEFAULT_TARGET)
        @service = Service.new(cf_client)
      end
    end

    before(:each) do
      cloudfoundry_set_user_cookies(CloudFoundry::Client::DEFAULT_TARGET)
    end

    use_vcr_cassette "controllers/logged/apps", :record => :new_episodes

    describe 'POST create' do
      it 'redirects to apps page with a flash alert when name is blank' do
        post :create, :name => "", :instances => "1", :memsize => "64", :type => "sinatra/ruby18",
             :url => "fakeapp.vcap.me", :gitrepo => "git://github.com/frodenas/cf-sinatra-sample.git"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/apps")
        flash[:alert].should include(I18n.t('apps.controller.name_blank'))
      end

      it 'redirects to apps page with a flash alert when instances is blank' do
        post :create, :name => "fakeapp", :instances => "", :memsize => "64", :type => "sinatra/ruby18",
             :url => "fakeapp.vcap.me", :gitrepo => "git://github.com/frodenas/cf-sinatra-sample.git"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/apps")
        flash[:alert].should include(I18n.t('apps.controller.instances_blank'))
      end

      it 'redirects to apps page with a flash alert when memsize is blank' do
        post :create, :name => "fakeapp", :instances => "1", :memsize => "", :type => "sinatra/ruby18",
             :url => "fakeapp.vcap.me", :gitrepo => "git://github.com/frodenas/cf-sinatra-sample.git"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/apps")
        flash[:alert].should include(I18n.t('apps.controller.memsize_blank'))
      end

      it 'redirects to apps page with a flash alert when type is blank' do
        post :create, :name => "fakeapp", :instances => "1", :memsize => "64", :type => "",
             :url => "fakeapp.vcap.me", :gitrepo => "git://github.com/frodenas/cf-sinatra-sample.git"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/apps")
        flash[:alert].should include(I18n.t('apps.controller.type_blank'))
      end

      it 'redirects to apps page with a flash alert when url is blank' do
        post :create, :name => "fakeapp", :instances => "1", :memsize => "64", :type => "sinatra/ruby18",
             :url => "", :gitrepo => "git://github.com/frodenas/cf-sinatra-sample.git"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/apps")
        flash[:alert].should include(I18n.t('apps.controller.url_blank'))
      end

      it 'redirects to apps page with a flash notice when app is created' do
        VCR.use_cassette("controllers/logged/app_create", :record => :new_episodes, :exclusive => true) do
          post :create, :name => "fakeapp", :instances => "1", :memsize => "64", :type => "sinatra/ruby18",
               :url => "fakeapp.vcap.me", :gitrepo => "git://github.com/frodenas/cf-sinatra-sample.git"
          response.code.should eq("302")
          response.should redirect_to("/" + I18n.locale.to_s + "/apps")
          flash[:notice].should include(I18n.t('apps.controller.app_created_bits_uploaded', :name =>"fakeapp"))
        end
      end

      it 'assigns app info as @new_app when app is created' do
        VCR.use_cassette("controllers/logged/app_create", :record => :new_episodes, :exclusive => true) do
          post :create, :name => "fakeapp", :instances => "1", :memsize => "64", :type => "sinatra/ruby18",
               :url => "fakeapp.vcap.me", :gitrepo => "git://github.com/frodenas/cf-sinatra-sample.git"
          assigns(:new_app).should_not be_nil
          assigns(:new_app).first[:name].should include("fakeapp")
        end
      end
    end

    describe 'PUT start' do
      it 'redirects to apps page with a flash alert when name is blank' do
        put :start, :name => ""
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/apps")
        flash[:alert].should include(I18n.t('apps.controller.name_blank'))
      end

      it 'redirects to apps page with a flash notice when app is started' do
        VCR.use_cassette("controllers/logged/app_start", :record => :new_episodes, :exclusive => true) do
          put :start, :name => "fakeapp"
          response.code.should eq("302")
          response.should redirect_to("/" + I18n.locale.to_s + "/apps")
          flash[:notice].should include(I18n.t('apps.controller.app_started', :name => "fakeapp"))
        end
      end

      it 'redirects to apps page with a flash alert when app does not exists' do
        put :start, :name => "noapp"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/apps")
        flash[:alert].should_not be_empty
      end
    end

    describe 'PUT set_instances' do
      it 'redirects to app page with a flash alert when name is blank' do
        put :set_instances, :name => "", :instances => "1"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/app/")
        flash[:alert].should include(I18n.t('apps.controller.name_blank'))
      end

      it 'redirects to app page with a flash alert when number of instances is blank' do
        put :set_instances, :name => "fakeapp", :instances => ""
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/app/fakeapp")
        flash[:alert].should include(I18n.t('apps.controller.instances_blank'))
      end

      it 'redirects to app page with a flash notice when app instances are set' do
        VCR.use_cassette("controllers/logged/app_set_instances", :record => :new_episodes, :exclusive => true) do
          put :set_instances, :name => "fakeapp", :instances => "1"
          response.code.should eq("302")
          response.should redirect_to("/" + I18n.locale.to_s + "/app/fakeapp")
          flash[:notice].should include(I18n.t('apps.controller.instances_set', :instances => "1"))
        end
      end

      it 'redirects to app page with a flash alert when app does not exists' do
        put :set_instances, :name => "noapp", :instances => "1"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/app/noapp")
        flash[:alert].should_not be_empty
      end
    end

    describe 'PUT set_instances.js' do
      it 'renders set_instances javascript page when name is blank' do
        put :set_instances, :format => :js, :name => "", :instances => "1"
        response.code.should eq("400")
        response.content_type.should eql("text/javascript")
        response.should render_template("apps/resources/set_instances")
      end

      it 'renders set_instances javascript page when number of instances is blank' do
        put :set_instances, :format => :js, :name => "fakeapp", :instances => ""
        response.code.should eq("400")
        response.content_type.should eql("text/javascript")
        response.should render_template("apps/resources/set_instances")
      end

      it 'renders set_instances javascript page when app instances are set' do
        VCR.use_cassette("controllers/logged/app_set_instances", :record => :new_episodes, :exclusive => true) do
          put :set_instances, :format => :js, :name => "fakeapp", :instances => "1"
          response.code.should eq("200")
          response.content_type.should eql("text/javascript")
          response.should render_template("apps/resources/set_instances")
        end
      end
    end

    describe 'PUT set_memsize' do
      it 'redirects to app page with a flash alert when name is blank' do
        put :set_memsize, :name => "", :memsize => "128"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/app/")
        flash[:alert].should include(I18n.t('apps.controller.name_blank'))
      end

      it 'redirects to app page with a flash alert when memory size is blank' do
        put :set_memsize, :name => "fakeapp", :memsize => ""
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/app/fakeapp")
        flash[:alert].should include(I18n.t('apps.controller.memsize_blank'))
      end

      it 'redirects to app page with a flash notice when app memory size is set' do
        VCR.use_cassette("controllers/logged/app_set_memsize", :record => :new_episodes, :exclusive => true) do
          put :set_memsize, :name => "fakeapp", :memsize => "128"
          response.code.should eq("302")
          response.should redirect_to("/" + I18n.locale.to_s + "/app/fakeapp")
          flash[:notice].should include(I18n.t('apps.controller.memsize_set', :memsize => "128"))
        end
      end

      it 'redirects to app page with a flash alert when app does not exists' do
        put :set_memsize, :name => "noapp", :memsize => "128"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/app/noapp")
        flash[:alert].should_not be_empty
      end
    end

    describe 'PUT set_memsize.js' do
      it 'renders set_memsize javascript page when name is blank' do
        put :set_memsize, :format => :js, :name => "", :memsize => "128"
        response.code.should eq("400")
        response.content_type.should eql("text/javascript")
        response.should render_template("apps/resources/set_memsize")
      end

      it 'renders set_memsize javascript page when memory size is blank' do
        put :set_memsize, :format => :js, :name => "fakeapp", :memsize => ""
        response.code.should eq("400")
        response.content_type.should eql("text/javascript")
        response.should render_template("apps/resources/set_memsize")
      end

      it 'renders set_memsize javascript page when app memory size is set' do
        VCR.use_cassette("controllers/logged/app_set_memsize", :record => :new_episodes, :exclusive => true) do
          put :set_memsize, :format => :js, :name => "fakeapp", :memsize => "128"
          response.code.should eq("200")
          response.content_type.should eql("text/javascript")
          response.should render_template("apps/resources/set_memsize")
        end
      end
    end

    describe 'PUT set_var' do
      it 'redirects to app page with a flash alert when name is blank' do
        put :set_var, :name => "", :var_name => "fakevar", :var_value => "fakevalue"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/app/")
        flash[:alert].should include(I18n.t('apps.controller.name_blank'))
      end

      it 'redirects to app page with a flash alert when varname is blank' do
        put :set_var, :name => "fakeapp", :var_name => "", :var_value => "fakevalue"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/app/fakeapp")
        flash[:alert].should include(I18n.t('apps.controller.varname_blank'))
      end

      it 'redirects to app page with a flash notice when envvar is set' do
        VCR.use_cassette("controllers/logged/app_set_var", :record => :new_episodes, :exclusive => true) do
          put :set_var, :name => "fakeapp", :var_name => "fakevar", :var_value => "fakevalue"
          response.code.should eq("302")
          response.should redirect_to("/" + I18n.locale.to_s + "/app/fakeapp")
          flash[:notice].should include(I18n.t('apps.controller.envvar_set', :var_name => "FAKEVAR"))
        end
      end

      it 'redirects to app page with a flash alert when app does not exists' do
        put :set_var, :name => "noapp", :var_name => "fakevar", :var_value => "fakevalue"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/app/noapp")
        flash[:alert].should_not be_empty
      end
    end

    describe 'PUT set_var.js' do
      it 'renders set_var javascript page when name is blank' do
        put :set_var, :format => :js, :name => "", :var_name => "fakevar", :var_value => "fakevalue"
        response.code.should eq("200")
        response.content_type.should eql("text/javascript")
        response.should render_template("apps/envvars/set_var")
      end

      it 'renders set_var javascript page when varname is blank' do
        put :set_var, :format => :js, :name => "fakeapp", :var_name => "", :var_value => "fakevalue"
        response.code.should eq("200")
        response.content_type.should eql("text/javascript")
        response.should render_template("apps/envvars/set_var")
      end

      it 'renders set_var javascript page when envvar is set' do
        VCR.use_cassette("controllers/logged/app_set_var", :record => :new_episodes, :exclusive => true) do
          put :set_var, :format => :js, :name => "fakeapp", :var_name => "fakevar", :var_value => "fakevalue"
          response.code.should eq("200")
          response.content_type.should eql("text/javascript")
          response.should render_template("apps/envvars/set_var")
        end
      end
    end

    describe 'PUT bind_service' do
      it 'redirects to app page with a flash alert when name is blank' do
        put :bind_service, :name => "", :service => "fakeservice"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/app/")
        flash[:alert].should include(I18n.t('apps.controller.name_blank'))
      end

      it 'redirects to app page with a flash alert when service is blank' do
        put :bind_service, :name => "fakeapp", :service => ""
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/app/fakeapp")
        flash[:alert].should include(I18n.t('apps.controller.service_blank'))
      end

      it 'redirects to app page with a flash notice when service is binded' do
        VCR.use_cassette("controllers/logged/app_bind_service", :record => :new_episodes, :exclusive => true) do
          created = @service.create("fakeservice", "redis")
          put :bind_service, :name => "fakeapp", :service => "fakeservice"
          response.code.should eq("302")
          response.should redirect_to("/" + I18n.locale.to_s + "/app/fakeapp")
          flash[:notice].should include(I18n.t('apps.controller.service_binded', :service => "fakeservice"))
        end
      end

      it 'redirects to app page with a flash alert when app does not exists' do
        put :bind_service, :name => "noapp", :service => "fakeservice"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/app/noapp")
        flash[:alert].should_not be_empty
      end
    end

    describe 'PUT bind_service.js' do
      it 'renders bind_service javascript page when name is blank' do
        put :bind_service, :format => :js, :name => "", :service => "fakeservice"
        response.code.should eq("200")
        response.content_type.should eql("text/javascript")
        response.should render_template("apps/services/bind_service")
      end

      it 'renders bind_service javascript page when service is blank' do
        put :bind_service, :format => :js, :name => "fakeapp", :service => ""
        response.code.should eq("200")
        response.content_type.should eql("text/javascript")
        response.should render_template("apps/services/bind_service")
      end

      it 'renders bind_service javascript page when service is binded' do
        VCR.use_cassette("controllers/logged/app_bind_service", :record => :new_episodes, :exclusive => true) do
          created = @service.create("fakeservice", "redis")
          put :bind_service, :format => :js, :name => "fakeapp", :service => "fakeservice"
          response.code.should eq("200")
          response.content_type.should eql("text/javascript")
          response.should render_template("apps/services/bind_service")
        end
      end
    end

    describe 'PUT map_url' do
      it 'redirects to app page with a flash alert when name is blank' do
        put :map_url, :name => "", :url => "http://fakeapp2.vcap.me"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/app/")
        flash[:alert].should include(I18n.t('apps.controller.name_blank'))
      end

      it 'redirects to app page with a flash alert when url is blank' do
        put :map_url, :name => "fakeapp", :url => ""
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/app/fakeapp")
        flash[:alert].should include(I18n.t('apps.controller.url_blank'))
      end

      it 'redirects to app page with a flash notice when url is mapped' do
        VCR.use_cassette("controllers/logged/app_map_url", :record => :new_episodes, :exclusive => true) do
          put :map_url, :name => "fakeapp", :url => "http://fakeapp2.vcap.me"
          response.code.should eq("302")
          response.should redirect_to("/" + I18n.locale.to_s + "/app/fakeapp")
          flash[:notice].should include(I18n.t('apps.controller.url_mapped', :url => "fakeapp2.vcap.me"))
        end
      end

      it 'redirects to app page with a flash alert when app does not exists' do
        put :map_url, :name => "noapp", :url => "http://fakeapp2.vcap.me"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/app/noapp")
        flash[:alert].should_not be_empty
      end
    end

    describe 'PUT map_url.js' do
      it 'renders map_url javascript page when name is blank' do
        put :map_url, :format => :js, :name => "", :url => "http://fakeapp2.vcap.me"
        response.code.should eq("200")
        response.content_type.should eql("text/javascript")
        response.should render_template("apps/urls/map_url")
      end

      it 'renders map_url javascript page when url is blank' do
        put :map_url, :format => :js, :name => "fakeapp", :url => ""
        response.code.should eq("200")
        response.content_type.should eql("text/javascript")
        response.should render_template("apps/urls/map_url")
      end

      it 'renders map_url javascript page when url is mapped' do
        VCR.use_cassette("controllers/logged/app_map_url", :record => :new_episodes, :exclusive => true) do
          put :map_url, :format => :js, :name => "fakeapp", :url => "http://fakeapp2.vcap.me"
          response.code.should eq("200")
          response.content_type.should eql("text/javascript")
          response.should render_template("apps/urls/map_url")
        end
      end
    end

    describe 'GET index' do
      it 'renders index page' do
        get :index
        response.code.should eq("200")
        response.should render_template("index")
      end

      it 'assigns applications info as @apps' do
        get :index
        assigns(:apps).should_not be_nil
      end

      it 'assigns applications info as @apps using EM and Fibers' do
        EM.synchrony do
          get :index
          assigns(:apps).should_not be_nil
          EM.stop
        end
      end

      it 'assigns @available_instances, @available_memsizes, @available_frameworks and @available_services' do
        get :index
        assigns(:available_instances).should_not be_nil
        assigns(:available_memsizes).should_not be_nil
        assigns(:available_frameworks).should_not be_nil
        assigns(:available_services).should_not be_nil
      end
    end

    describe 'GET show' do
      it 'redirects to apps page with a flash alert when name is blank' do
        get :show, :name => ""
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/apps")
        flash[:alert].should include(I18n.t('apps.controller.name_blank'))
      end

      it 'renders show page' do
        get :show, :name => "fakeapp"
        response.code.should eq("200")
        response.should render_template("show")
      end

      it 'assigns application info as @apps and @app_files' do
        get :show, :name => "fakeapp"
        assigns(:app).should_not be_nil
        assigns(:app).should_not be_empty
        assigns(:app_files).should_not be_nil
      end

      it 'assigns application info as @apps and @app_files using EM and Fibers' do
        EM.synchrony do
          get :show, :name => "fakeapp"
          assigns(:app).should_not be_nil
          assigns(:app).should_not be_empty
          assigns(:app_files).should_not be_nil
          EM.stop
        end
      end

      it 'assigns @available_instances, @available_memsizes and @available_services' do
        get :show, :name => "fakeapp"
        assigns(:available_instances).should_not be_nil
        assigns(:available_memsizes).should_not be_nil
        assigns(:available_services).should_not be_nil
      end

      it 'redirects to apps page with a flash alert when app does not exists' do
        get :show, :name => "noapp"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/apps")
        flash[:alert].should_not be_empty
      end
    end

    describe 'PUT unset_var' do
      it 'redirects to app page with a flash alert when name is blank' do
        put :unset_var, :name => "", :var_name => "fakevar", :var_value => "fakevalue"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/app/")
        flash[:alert].should include(I18n.t('apps.controller.name_blank'))
      end

      it 'redirects to app page with a flash alert when varname is blank' do
        put :unset_var, :name => "fakeapp", :var_name => "", :var_value => "fakevalue"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/app/fakeapp")
        flash[:alert].should include(I18n.t('apps.controller.varname_blank'))
      end

      it 'redirects to app page with a flash notice when envvar is unset' do
        VCR.use_cassette("controllers/logged/app_unset_var", :record => :new_episodes, :exclusive => true) do
          put :unset_var, :name => "fakeapp", :var_name => "fakevar", :var_value => "fakevalue"
          response.code.should eq("302")
          response.should redirect_to("/" + I18n.locale.to_s + "/app/fakeapp")
          flash[:notice].should include(I18n.t('apps.controller.envvar_unset', :var_name => "FAKEVAR"))
        end
      end

      it 'redirects to app page with a flash alert when app does not exists' do
        put :unset_var, :name => "noapp", :var_name => "fakevar", :var_value => "fakevalue"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/app/noapp")
        flash[:alert].should_not be_empty
      end
    end

    describe 'PUT unset_var.js' do
      it 'renders unset_var javascript page when name is blank' do
        put :unset_var, :format => :js, :name => "", :var_name => "fakevar", :var_value => "fakevalue"
        response.code.should eq("200")
        response.content_type.should eql("text/javascript")
        response.should render_template("apps/envvars/unset_var")
      end

      it 'renders unset_var javascript page when varname is blank' do
        put :unset_var, :format => :js, :name => "fakeapp", :var_name => "", :var_value => "fakevalue"
        response.code.should eq("200")
        response.content_type.should eql("text/javascript")
        response.should render_template("apps/envvars/unset_var")
      end

      it 'renders unset_var javascript page when envvar is unset' do
        VCR.use_cassette("controllers/logged/app_unset_var", :record => :new_episodes, :exclusive => true) do
          put :unset_var, :format => :js, :name => "fakeapp", :var_name => "fakevar", :var_value => "fakevalue"
          response.code.should eq("200")
          response.content_type.should eql("text/javascript")
          response.should render_template("apps/envvars/unset_var")
        end
      end
    end

    describe 'PUT unbind_service' do
      it 'redirects to app page with a flash alert when name is blank' do
        put :unbind_service, :name => "", :service => "fakeservice"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/app/")
        flash[:alert].should include(I18n.t('apps.controller.name_blank'))
      end

      it 'redirects to app page with a flash alert when service is blank' do
        put :unbind_service, :name => "fakeapp", :service => ""
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/app/fakeapp")
        flash[:alert].should include(I18n.t('apps.controller.service_blank'))
      end

      it 'redirects to app page with a flash notice when service is unbinded' do
        VCR.use_cassette("controllers/logged/app_unbind_service", :record => :new_episodes, :exclusive => true) do
          put :unbind_service, :name => "fakeapp", :service => "fakeservice"
          response.code.should eq("302")
          response.should redirect_to("/" + I18n.locale.to_s + "/app/fakeapp")
          flash[:notice].should include(I18n.t('apps.controller.service_unbinded', :service => "fakeservice"))
          deleted = @service.delete("fakeservice")
        end
      end

      it 'redirects to app page with a flash alert when app does not exists' do
        put :unbind_service, :name => "noapp", :service => "fakeservice"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/app/noapp")
        flash[:alert].should_not be_empty
      end
    end

    describe 'PUT unbind_service.js' do
      it 'renders unbind_service javascript page when name is blank' do
        put :unbind_service, :format => :js, :name => "", :service => "fakeservice"
        response.code.should eq("200")
        response.content_type.should eql("text/javascript")
        response.should render_template("apps/services/unbind_service")
      end

      it 'renders unbind_service javascript page when service is blank' do
        put :unbind_service, :format => :js, :name => "fakeapp", :service => ""
        response.code.should eq("200")
        response.content_type.should eql("text/javascript")
        response.should render_template("apps/services/unbind_service")
      end

      it 'renders unbind_service javascript page when service is unbinded' do
        VCR.use_cassette("controllers/logged/app_unbind_service", :record => :new_episodes, :exclusive => true) do
          put :unbind_service, :format => :js, :name => "fakeapp", :service => "fakeservice"
          response.code.should eq("200")
          response.content_type.should eql("text/javascript")
          response.should render_template("apps/services/unbind_service")
          deleted = @service.delete("fakeservice")
        end
      end
    end

    describe 'PUT unmap_url' do
      it 'redirects to app page with a flash alert when name is blank' do
        put :unmap_url, :name => "", :url => "http://fakeapp2.vcap.me"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/app/")
        flash[:alert].should include(I18n.t('apps.controller.name_blank'))
      end

      it 'redirects to app page with a flash alert when url is blank' do
        put :unmap_url, :name => "fakeapp", :url => ""
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/app/fakeapp")
        flash[:alert].should include(I18n.t('apps.controller.url_blank'))
      end

      it 'redirects to app page with a flash notice when url is unmapped' do
        VCR.use_cassette("controllers/logged/app_unmap_url", :record => :new_episodes, :exclusive => true) do
          put :unmap_url, :name => "fakeapp", :url => "http://fakeapp2.vcap.me"
          response.code.should eq("302")
          response.should redirect_to("/" + I18n.locale.to_s + "/app/fakeapp")
          flash[:notice].should include(I18n.t('apps.controller.url_unmapped', :url => "fakeapp2.vcap.me"))
        end
      end

      it 'redirects to app page with a flash alert when app does not exists' do
        put :unmap_url, :name => "noapp", :url => "http://fakeapp2.vcap.me"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/app/noapp")
        flash[:alert].should_not be_empty
      end
    end

    describe 'PUT unmap_url.js' do
      it 'renders unmap_url javascript page when name is blank' do
        put :unmap_url, :format => :js, :name => "", :url => "http://fakeapp2.vcap.me"
        response.code.should eq("200")
        response.content_type.should eql("text/javascript")
        response.should render_template("apps/urls/unmap_url")
      end

      it 'renders unmap_url javascript page when url is blank' do
        put :unmap_url, :format => :js, :name => "fakeapp", :url => ""
        response.code.should eq("200")
        response.content_type.should eql("text/javascript")
        response.should render_template("apps/urls/unmap_url")
      end

      it 'renders unmap_url javascript page when url is unmapped' do
        VCR.use_cassette("controllers/logged/app_unmap_url", :record => :new_episodes, :exclusive => true) do
          put :unmap_url, :format => :js, :name => "fakeapp", :url => "http://fakeapp2.vcap.me"
          response.code.should eq("200")
          response.content_type.should eql("text/javascript")
          response.should render_template("apps/urls/unmap_url")
        end
      end
    end

    describe 'PUT update_bits' do
      it 'redirects to apps page with a flash alert when name is blank' do
        put :update_bits, :name => "", :gitrepo => "git://github.com/frodenas/cf-sinatra-sample.git"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/apps")
        flash[:alert].should include(I18n.t('apps.controller.name_blank'))
      end

      it 'redirects to apps page with a flash alert when gitrepo is blank' do
        put :update_bits, :name => "fakeapp", :gitrepo => ""
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/apps")
        flash[:alert].should include(I18n.t('apps.controller.gitrepo_blank'))
      end

      it 'redirects to apps page with a flash alert when gitrepo is invalid' do
        put :update_bits, :name => "fakeapp", :gitrepo => "git://github.com/frodenas/cf-sinatra-sample"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/apps")
        flash[:alert].should include(I18n.t('apps.controller.gitrepo_invalid'))
      end

      it 'redirects to apps page with a flash notice when app bits are updated' do
        VCR.use_cassette("controllers/logged/app_update_bits", :record => :new_episodes, :exclusive => true) do
          put :update_bits, :name => "fakeapp", :gitrepo => "git://github.com/frodenas/cf-sinatra-sample.git"
          response.code.should eq("302")
          response.should redirect_to("/" + I18n.locale.to_s + "/apps")
          flash[:notice].should include(I18n.t('apps.controller.bits_uploaded', :name => "fakeapp"))
        end
      end

      it 'redirects to apps page with a flash alert when app does not exists' do
        put :update_bits, :name => "noapp", :gitrepo => "git://github.com/frodenas/cf-sinatra-sample.git"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/apps")
        flash[:alert].should_not be_empty
      end
    end

    describe 'GET download_bits' do
      it 'redirects to app page with a flash alert when name is blank' do
        get :download_bits, :name => ""
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/app/")
        flash[:alert].should include(I18n.t('apps.controller.name_blank'))
      end

      it 'sends applications bits as a zip file' do
        VCR.use_cassette("controllers/logged/app_download_bits", :record => :new_episodes, :exclusive => true) do
          get :download_bits, :name => "fakeapp"
          response.code.should eq("200")
          response.header["Content-Type"].should eql("application/zip")
          response.header["Content-Disposition"].should eql("attachment; filename=\"fakeapp.zip\"")
          response.body.should_not be_nil
        end
      end

      it 'redirects to app page with a flash alert when app does not exists' do
        get :download_bits, :name => "noapp"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/app/noapp")
        flash[:alert].should_not be_empty
      end
    end

    describe 'GET files' do
      it 'redirects to app page with a flash alert when name is blank' do
        get :files, :name => "", :instance => 0, :filename => Base64.encode64("/")
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/app/")
        flash[:alert].should include(I18n.t('apps.controller.name_blank'))
      end

      it 'redirects to app page with a flash alert when filename is blank' do
        get :files, :name => "fakeapp", :instance => 0, :filename => ""
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/app/fakeapp")
        flash[:alert].should include(I18n.t('apps.controller.filename_blank'))
      end

      it 'redirects to app page and assigns files as @app_files' do
        VCR.use_cassette("controllers/logged/app_files", :record => :new_episodes, :exclusive => true) do
          get :files, :name => "fakeapp", :instance => 0, :filename => Base64.encode64("/")
          response.code.should eq("302")
          response.should redirect_to("/" + I18n.locale.to_s + "/app/fakeapp")
          assigns(:app_files).should_not be_nil
        end
      end

      it 'redirects to app page and assigns files as an empty @app_files' do
        get :files, :name => "noapp", :instance => 0, :filename => Base64.encode64("/")
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/app/noapp")
        assigns(:app_files).should_not be_nil
        assigns(:app_files).should be_empty
      end
    end

    describe 'GET files.js' do
      it 'renders files javascript page when name is blank' do
        get :files, :format => :js, :name => "", :instance => 0, :filename => Base64.encode64("/")
        response.code.should eq("200")
        response.content_type.should eql("text/javascript")
        response.should render_template("apps/files/files")
      end

      it 'renders files javascript page when filename is blank' do
        get :files, :format => :js, :name => "fakeapp", :instance => 0, :filename => ""
        response.code.should eq("200")
        response.content_type.should eql("text/javascript")
        response.should render_template("apps/files/files")
      end

      it 'renders files javascript page' do
        VCR.use_cassette("controllers/logged/app_files", :record => :new_episodes, :exclusive => true) do
          get :files, :format => :js, :name => "fakeapp", :instance => 0, :filename => Base64.encode64("/")
          response.code.should eq("200")
          response.content_type.should eql("text/javascript")
          response.should render_template("apps/files/files")
        end
      end
    end

    describe 'GET view_file' do
      it 'renders app_view_file page with a flash alert when name is blank' do
        get :view_file, :name => "", :instance => 0, :filename => Base64.encode64("logs/stdout.log")
        response.code.should eq("200")
        response.should render_template("apps/files/app_view_file")
        flash[:alert].should include(I18n.t('apps.controller.name_blank'))
      end

      it 'renders app_view_file page with a flash alert when filename is blank' do
        get :view_file, :name => "fakeapp", :instance => 0, :filename => ""
        response.code.should eq("200")
        response.should render_template("apps/files/app_view_file")
        flash[:alert].should include(I18n.t('apps.controller.filename_blank'))
      end

      it 'renders app_view_file page and assigns file contents as @file_contents (with syntax highlight)' do
        VCR.use_cassette("controllers/logged/app_view_file", :record => :new_episodes, :exclusive => true) do
          get :view_file, :name => "fakeapp", :instance => 0, :filename => Base64.encode64("logs/stdout.log")
          response.code.should eq("200")
          response.should render_template("apps/files/app_view_file")
          assigns(:file_contents).should_not be_nil
          assigns(:file_loc).should_not be_nil
        end
      end

      it 'renders app_view_file page and assigns file contents as @file_contents (without syntax highlight)' do
        VCR.use_cassette("controllers/logged/app_view_file", :record => :new_episodes, :exclusive => true) do
          get :view_file, :name => "fakeapp", :instance => 0, :filename => Base64.encode64("logs/stdout.log"), :formatcode => "false"
          response.code.should eq("200")
          response.should render_template("apps/files/app_view_file")
          assigns(:file_contents).should_not be_nil
          assigns(:file_loc).should be_nil
        end
      end

      it 'renders app_view_file page with a flash alert when app does not exists' do
        get :view_file, :name => "noapp", :instance => 0, :filename => Base64.encode64("logs/stdout.log")
        response.code.should eq("200")
        response.should render_template("apps/files/app_view_file")
        flash[:alert].should_not be_empty
      end
    end

    describe 'GET view_file.js' do
      it 'renders view_file javascript page when name is blank' do
        get :view_file, :format => :js, :name => "", :instance => 0, :filename => Base64.encode64("logs/stdout.log")
        response.code.should eq("200")
        response.content_type.should eql("text/javascript")
        response.should render_template("apps/files/view_file")
      end

      it 'renders view_file javascript page when filename is blank' do
        get :view_file, :format => :js, :name => "fakeapp", :instance => 0, :filename => ""
        response.code.should eq("200")
        response.content_type.should eql("text/javascript")
        response.should render_template("apps/files/view_file")
      end

      it 'renders view_file javascript page' do
        VCR.use_cassette("controllers/logged/app_view_file", :record => :new_episodes, :exclusive => true) do
          get :view_file, :format => :js, :name => "fakeapp", :instance => 0, :filename => Base64.encode64("logs/stdout.log")
          response.code.should eq("200")
          response.content_type.should eql("text/javascript")
          response.should render_template("apps/files/view_file")
        end
      end
    end

    describe 'PUT restart' do
      it 'redirects to apps page with a flash alert when name is blank' do
        put :restart, :name => ""
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/apps")
        flash[:alert].should include(I18n.t('apps.controller.name_blank'))
      end

      it 'redirects to apps page with a flash notice when app is restarted' do
        VCR.use_cassette("controllers/logged/app_restart", :record => :new_episodes, :exclusive => true) do
          put :restart, :name => "fakeapp"
          response.code.should eq("302")
          response.should redirect_to("/" + I18n.locale.to_s + "/apps")
          flash[:notice].should include(I18n.t('apps.controller.app_restarted', :name => "fakeapp"))
        end
      end

      it 'redirects to apps page with a flash alert when app does not exists' do
        put :restart, :name => "noapp"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/apps")
        flash[:alert].should_not be_empty
      end
    end

    describe 'PUT stop' do
      it 'redirects to apps page with a flash alert when name is blank' do
        put :stop, :name => ""
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/apps")
        flash[:alert].should include(I18n.t('apps.controller.name_blank'))
      end

      it 'redirects to apps page with a flash notice when app is stopped' do
        VCR.use_cassette("controllers/logged/app_stop", :record => :new_episodes, :exclusive => true) do
          put :stop, :name => "fakeapp"
          response.code.should eq("302")
          response.should redirect_to("/" + I18n.locale.to_s + "/apps")
          flash[:notice].should include(I18n.t('apps.controller.app_stopped', :name => "fakeapp"))
        end
      end

      it 'redirects to apps page with a flash alert when app does not exists' do
        put :stop, :name => "noapp"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/apps")
        flash[:alert].should_not be_empty
      end
    end

    describe 'DELETE delete' do
      it 'redirects to apps page with a flash alert when name is blank' do
        delete :delete, :name => ""
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/apps")
        flash[:alert].should include(I18n.t('apps.controller.name_blank'))
      end

      it 'redirects to apps page with a flash notice when app is deleted' do
        delete :delete, :name => "fakeapp"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/apps")
        flash[:notice].should include(I18n.t('apps.controller.app_deleted', :name => "fakeapp"))
      end

      it 'redirects to apps page with a flash alert when app does not exists' do
        delete :delete, :name => "noapp"
        response.code.should eq("302")
        response.should redirect_to("/" + I18n.locale.to_s + "/apps")
        flash[:alert].should_not be_empty
      end
    end
  end
end