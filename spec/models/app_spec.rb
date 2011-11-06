require 'spec_helper'

describe App do
  include CfConnectionHelper

  context "without a user logged in" do
    before(:all) do
      VCR.use_cassette("models/no_logged/client", :record => :new_episodes) do
        cf_client = vmc_client(VMC::DEFAULT_LOCAL_TARGET)
        @app = App.new(cf_client)
      end
    end

    use_vcr_cassette "models/no_logged/app", :record => :new_episodes

    it 'raises an AuthError exception when looking for all apps' do
      expect {
        apps = @app.find_all_apps()
      }.to raise_exception(VMC::Client::AuthError)
    end

    it 'raises an AuthError exception when looking for all app states' do
      expect {
        apps_states = @app.find_all_states()
      }.to raise_exception(VMC::Client::AuthError)
    end

    it 'raises an AuthError exception when looking for an app' do
      expect {
        app_info = @app.find("app-mock-started")
      }.to raise_exception(VMC::Client::AuthError)
    end

    it 'raises an AuthError exception when looking for app instances' do
      expect {
        app_instances = @app.find_app_instances("app-mock-started")
      }.to raise_exception(VMC::Client::AuthError)
    end

    it 'raises an AuthError exception when looking for app crashes' do
      expect {
        app_crashes = @app.find_app_crashes("app-mock-started")
      }.to raise_exception(VMC::Client::AuthError)
    end

    it 'returns an empty list of app states' do
      app_states = @app.find_app_instances_states(nil)
      app_states.should be_empty
    end

    it 'raises an AuthError exception when stopping an app' do
      expect {
        app_info = @app.stop("app-mock-started")
      }.to raise_exception(VMC::Client::AuthError)
    end

    it 'raises an AuthError exception when starting an app' do
      expect {
        app_info = @app.start("app-mock-started")
      }.to raise_exception(VMC::Client::AuthError)
    end

    it 'raises an AuthError exception when restarting an app' do
      expect {
        app_info = @app.restart("app-mock-started")
      }.to raise_exception(VMC::Client::AuthError)
    end

    it 'raises an AuthError exception when deleting an app' do
      expect {
        app_info = @app.delete("app-mock-started")
      }.to raise_exception(VMC::Client::AuthError)
    end

    it 'raises an AuthError exception when setting app number of instances' do
      expect {
        @app.set_instances("app-mock-started", "1")
      }.to raise_exception(VMC::Client::AuthError)
    end

    it 'raises an AuthError exception when setting app memory size' do
      expect {
        @app.set_memsize("app-mock-started", "128")
      }.to raise_exception(VMC::Client::AuthError)
    end

    it 'raises an AuthError exception when setting an app var' do
      expect {
        var_exists = @app.set_var("app-mock-started", "var-mock", "value-mock")
      }.to raise_exception(VMC::Client::AuthError)
    end

    it 'raises an AuthError exception when unsetting an app var' do
      expect {
        @app.unset_var("app-mock-started", "var-mock")
      }.to raise_exception(VMC::Client::AuthError)
    end

    it 'raises an AuthError exception when binding a service' do
      expect {
        @app.bind_service("app-mock-started", "redis-mock")
      }.to raise_exception(VMC::Client::AuthError)
    end

    it 'raises an AuthError exception when unbinding a service' do
      expect {
        @app.unbind_service("app-mock-started", "redis-mock")
      }.to raise_exception(VMC::Client::AuthError)
    end

    it 'raises an AuthError exception when mapping a url' do
      expect {
        app_url = @app.map_url("app-mock-started", "http://app-mock.vcap.me")
      }.to raise_exception(VMC::Client::AuthError)
    end

    it 'raises an AuthError exception when unmapping a url' do
      expect {
        app_url = @app.unmap_url("app-mock-started", "http://app-mock.vcap.me")
      }.to raise_exception(VMC::Client::AuthError)
    end

    it 'raises an AuthError exception when viewing a file' do
      expect {
        files = @app.view_file("app-mock-started", "/", "0")
      }.to raise_exception(VMC::Client::AuthError)
    end
  end

  context "with a user logged in" do
    before(:all) do
      VCR.use_cassette("models/logged/client", :record => :new_episodes) do
        cf_client = vmc_client_user_logged(VMC::DEFAULT_LOCAL_TARGET)
        @app = App.new(cf_client)
      end
    end

    use_vcr_cassette "models/logged/app", :record => :new_episodes

    it 'returns a proper list of all apps' do
      apps = @app.find_all_apps()
      apps.should have_at_least(2).items
      app_info = apps.first
      app_info.should have_key :name
      app_info.should have_key :version
      app_info.should have_key :state
      app_info.should have_key :instances
      app_info.should have_key :runningInstances
      app_info.should have_key :staging
      app_info.should have_key :resources
      app_info.should have_key :uris
      app_info.should have_key :env
      app_info.should have_key :meta
    end

    it 'returns a proper list of all app states' do
      apps_states = @app.find_all_states()
      apps_states.should_not be_empty
    end

    it 'returns info about a started app' do
      app_info = @app.find("app-mock-started")
      app_info.should have_key :name
      app_info.should have_key :version
      app_info.should have_key :state
      app_info.should have_key :instances
      app_info.should have_key :runningInstances
      app_info.should have_key :staging
      app_info.should have_key :resources
      app_info.should have_key :uris
      app_info.should have_key :env
      app_info.should have_key :meta
    end

    it 'returns info about a stopped app' do
      app_info = @app.find("app-mock-stopped")
      app_info.should have_key :name
      app_info.should have_key :version
      app_info.should have_key :state
      app_info.should have_key :instances
      app_info.should have_key :runningInstances
      app_info.should have_key :staging
      app_info.should have_key :resources
      app_info.should have_key :uris
      app_info.should have_key :env
      app_info.should have_key :meta
    end

    it 'raises a NotFound exception when looking for an app that does not exists' do
      expect {
        app_info = @app.find("no-app-mock")
      }.to raise_exception(VMC::Client::NotFound)
    end

    it 'returns a proper list of instances if the app is started' do
      app_instances = @app.find_app_instances("app-mock-started")
      app_instances.should_not be_empty
    end

    it 'returns an empty list of instances if the app is stopped' do
      app_instances = @app.find_app_instances("app-mock-stopped")
      app_instances.should be_empty
    end

    it 'raises a NotFound exception when looking for instances of an app that does not exists' do
      expect {
        app_instances = @app.find_app_instances("no-app-mock")
      }.to raise_exception(VMC::Client::NotFound)
    end

    it 'returns an empty list of crashes if the app is started' do
      app_crashes = @app.find_app_crashes("app-mock-started")
      app_crashes.should be_empty
    end

    it 'returns an empty list of crashes if the app is stopped' do
      app_crashes = @app.find_app_crashes("app-mock-stopped")
      app_crashes.should be_empty
    end

    it 'raises a NotFound exception when looking for crashes of an app that does not exists' do
      expect {
        app_crashes = @app.find_app_crashes("no-app-mock")
      }.to raise_exception(VMC::Client::NotFound)
    end

    it 'returns a proper list of states if the app is started' do
      app_info = @app.find("app-mock-started")
      app_states = @app.find_app_instances_states(app_info)
      app_states.should_not be_empty
    end

    it 'returns a proper list of states if the app is stopped' do
      app_info = @app.find("app-mock-stopped")
      app_states = @app.find_app_instances_states(app_info)
      app_states.should_not be_empty
    end

    it 'can stop an app if the app is started' do
      VCR.use_cassette("models/logged/app_started_stop_action", :record => :new_episodes, :exclusive => true) do
        # TODO
        #app_info = @app.stop("app-mock-started")
      end
    end

    it 'can start an app if the app is started' do
      VCR.use_cassette("models/logged/app_started_start_action", :record => :new_episodes, :exclusive => true) do
        # TODO
        #app_info = @app.start("app-mock-started")
      end
    end

    it 'can restart an app if the app is started' do
      VCR.use_cassette("models/logged/app_started_restart_action", :record => :new_episodes, :exclusive => true) do
        # TODO
        #app_info = @app.restart("app-mock-started")
      end
    end

    it 'can start an app if the app is stopped' do
      VCR.use_cassette("models/logged/app_stopped_start_action", :record => :new_episodes, :exclusive => true) do
        # TODO
        #app_info = @app.start("app-mock-stopped")
      end
    end

    it 'can restart an app if the app is stopped' do
      VCR.use_cassette("models/logged/app_stopped_restart_action", :record => :new_episodes, :exclusive => true) do
        # TODO
        #app_info = @app.restart("app-mock-stopped")
      end
    end

    it 'can stop an app if the app is stopped' do
      VCR.use_cassette("models/logged/app_stopped_stop_action", :record => :new_episodes, :exclusive => true) do
        # TODO
        #app_info = @app.stop("app-mock-stopped")
      end
    end

    it 'raises a NotFound exception when stopping an app that does not exists' do
      expect {
        app_info = @app.stop("no-app-mock")
      }.to raise_exception(VMC::Client::NotFound)
    end

    it 'raises a NotFound exception when starting an app that does not exists' do
      expect {
        app_info = @app.start("no-app-mock")
      }.to raise_exception(VMC::Client::NotFound)
    end

    it 'raises a NotFound exception when restarting an app that does not exists' do
      expect {
        app_info = @app.restart("no-app-mock")
      }.to raise_exception(VMC::Client::NotFound)
    end

    it 'can set a var if the app is started' do
      VCR.use_cassette("models/logged/app_started_set_var_action", :record => :new_episodes, :exclusive => true) do
        # TODO
        #var_exists = @app.set_var("app-mock-started", "var-mock", "value-mock")
      end
    end

    it 'can set a var if the app is stopped' do
      VCR.use_cassette("models/logged/app_stopped_set_var_action", :record => :new_episodes, :exclusive => true) do
        # TODO
        #var_exists = @app.set_var("app-mock-stopped", "var-mock", "value-mock")
      end
    end

    it 'raises a NotFound exception when setting a var if the app does not exists' do
      expect {
        var_exists = @app.set_var("no-app-mock", "var-mock", "value-mock")
      }.to raise_exception(VMC::Client::NotFound)
    end

    it 'can modify a var if the app is started' do
      VCR.use_cassette("models/logged/app_started_modify_var_action", :record => :new_episodes, :exclusive => true) do
        # TODO
        #var_exists = @app.set_var("app-mock-started", "var-mock", "value-mock-2")
      end
    end

    it 'can modify a var if the app is stopped' do
      VCR.use_cassette("models/logged/app_stopped_modify_var_action", :record => :new_episodes, :exclusive => true) do
        # TODO
        #var_exists = @app.set_var("app-mock-stopped", "var-mock", "value-mock-2")
      end
    end

    it 'raises a NotFound exception when modifying a var if the app does not exists' do
      expect {
        var_exists = @app.set_var("no-app-mock", "var-mock", "value-mock-2")
      }.to raise_exception(VMC::Client::NotFound)
    end

    it 'can unset a var if the app is started' do
      VCR.use_cassette("models/logged/app_started_unset_var_action", :record => :new_episodes, :exclusive => true) do
        # TODO
        #@app.unset_var("app-mock-started", "var-mock")
      end
    end

    it 'can unset a var if the app is stopped' do
      VCR.use_cassette("models/logged/app_stopped_unset_var_action", :record => :new_episodes, :exclusive => true) do
        # TODO
        #@app.unset_var("app-mock-stopped", "var-mock")
      end
    end

    it 'raises a NotFound exception when unsetting a var if the app does not exists' do
      expect {
        var_exists = @app.unset_var("no-app-mock", "var-mock")
      }.to raise_exception(VMC::Client::NotFound)
    end

    it 'can bind a service if the app is started' do
      VCR.use_cassette("models/logged/app_started_bind_service_action", :record => :new_episodes, :exclusive => true) do
        # TODO
        #@app.bind_service("app-mock-started", "redis-mock")
      end
    end

    it 'raises a NotFound exception when binding a service that does not exists' do
      expect {
        @app.bind_service("app-mock-started", "no-service")
      }.to raise_exception(VMC::Client::NotFound)
    end

    it 'can bind a service if the app is stopped' do
      VCR.use_cassette("models/logged/app_stopped_bind_service_action", :record => :new_episodes, :exclusive => true) do
        # TODO
        #@app.bind_service("app-mock-stopped", "redis-mock")
      end
    end

    it 'raises a NotFound exception when binding a service if the app does not exists' do
      expect {
        @app.bind_service("no-app-mock", "redis-mock")
      }.to raise_exception(VMC::Client::NotFound)
    end

    it 'can unbind a service if the app is started' do
      VCR.use_cassette("models/logged/app_started_unbind_service_action", :record => :new_episodes, :exclusive => true) do
        # TODO
        #@app.unbind_service("app-mock-started", "redis-mock")
      end
    end

    it 'raises a RuntimeError exception when unbinding a service that is not binded' do
      expect {
        @app.unbind_service("app-mock-started", "no-service")
      }.to raise_exception(RuntimeError)
    end

    it 'can unbind a service if the app is stopped' do
      VCR.use_cassette("models/logged/app_stopped_unbind_service_action", :record => :new_episodes, :exclusive => true) do
        # TODO
        #@app.unbind_service("app-mock-stopped", "redis-mock")
      end
    end

    it 'raises a NotFound exception when unbinding a service if the app does not exists' do
      expect {
        @app.unbind_service("no-app-mock", "redis-mock")
      }.to raise_exception(VMC::Client::NotFound)
    end

    it 'can map a url if the app is started' do
      VCR.use_cassette("models/logged/app_started_map_url_action", :record => :new_episodes, :exclusive => true) do
        # TODO
        #app_url = @app.map_url("app-mock-started", "http://app-mock.vcap.me")
      end
    end

    it 'can not map an external url' do
      VCR.use_cassette("models/logged/app_started_map_external_url_action", :record => :new_episodes, :exclusive => true) do
        # Disable this test only if app_uris - allow_external is true in cloud_controller.yml
        expect {
          app_url = @app.map_url("app-mock-started", "http://app-mock.example.com")
        }.to raise_exception(VMC::Client::TargetError)
      end
    end

    it 'can not map a reserved url' do
      VCR.use_cassette("models/logged/app_started_map_reserved_url_action", :record => :new_episodes, :exclusive => true) do
        # Disable this test only if app_uris - reserved_list is not set in cloud_controller.yml
        expect {
          app_url = @app.map_url("app-mock-started", "http://www.vcap.me")
        }.to raise_exception(VMC::Client::NotFound)
      end
    end

    it 'can map a url if the app is stopped' do
      VCR.use_cassette("models/logged/app_stopped_map_url_action", :record => :new_episodes, :exclusive => true) do
        # TODO
        #app_url = @app.map_url("app-mock-stopped", "http://app-mock.vcap.me")
      end
    end

    it 'raises a NotFound exception when mapping a url if the app does not exists' do
      expect {
        app_url = @app.map_url("no-app-mock", "http://app-mock.vcap.me")
      }.to raise_exception(VMC::Client::NotFound)
    end

    it 'can unmap a url if the app is started' do
      VCR.use_cassette("models/logged/app_started_unmap_url_action", :record => :new_episodes, :exclusive => true) do
        # TODO
        #app_url = @app.unmap_url("app-mock-started", "http://app-mock.vcap.me")
      end
    end

    it 'raises a RuntimeError exception when unmapping a url that is not mapped' do
      expect {
        @app.unmap_url("app-mock-started", "http://no-url.vcap.me")
      }.to raise_exception(RuntimeError)
    end

    it 'can unmap a url if the app is stopped' do
      VCR.use_cassette("models/logged/app_stopped_unmap_url_action", :record => :new_episodes, :exclusive => true) do
        # TODO
        #app_url = @app.unmap_url("app-mock-stopped", "http://app-mock.vcap.me")
      end
    end

    it 'raises a NotFound exception when unmapping a url if the app does not exists' do
      expect {
        app_url = @app.unmap_url("no-app-mock", "http://app-mock.vcap.me")
      }.to raise_exception(VMC::Client::NotFound)
    end

    it 'returns a proper list of files when viewing files of a started app' do
      files = @app.view_file("app-mock-started", "/", "0")
      files.should_not be_empty
    end

    it 'raises an NotFound exception when viewing files of a stopped app' do
      expect {
        files = @app.view_file("app-mock-stopped", "/", "0")
      }.to raise_exception(VMC::Client::NotFound)
    end

    it 'raises an NotFound exception when viewing files of of an app that does not exists' do
      expect {
        files = @app.view_file("no-app-mock", "/", "0")
      }.to raise_exception(VMC::Client::NotFound)
    end

    it 'can delete an app if the app is started' do
      # TODO Disabled until a create method is developed
      #app_info = @app.delete("app-mock-started")
    end

    it 'can delete an app if the app is stopped' do
      # TODO Disabled until a create method is developed
      #app_info = @app.delete("app-mock-stopped")
    end

    it 'raises a NotFound exception when deleting an app that does not exists' do
      expect {
        app_info = @app.delete("no-app-mock")
      }.to raise_exception(VMC::Client::NotFound)
    end
  end
end