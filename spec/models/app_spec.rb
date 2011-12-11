require 'spec_helper'

describe App do
  include CfConnectionHelper

  context "without a user logged in" do
    before(:all) do
      VCR.use_cassette("models/no_logged/client", :record => :new_episodes) do
        cf_client = cloudfoundry_client(CloudFoundry::Client::DEFAULT_TARGET)
        @app = App.new(cf_client)
      end
    end

    use_vcr_cassette "models/no_logged/app", :record => :new_episodes

    it 'raises an exception when creating an app' do
      expect {
        created = @app.create("newapp", "1", "64", "newapp.vcap.me", "node", "node", "")
      }.to raise_exception
    end

    it 'raises an AuthError exception when looking for all apps' do
      expect {
        apps = @app.find_all_apps()
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when looking for all app states' do
      expect {
        apps_states = @app.find_all_states()
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when looking for an app' do
      expect {
        app_info = @app.find("newapp")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when looking for app instances' do
      expect {
        app_instances = @app.find_app_instances("newapp")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when looking for app crashes' do
      expect {
        app_crashes = @app.find_app_crashes("newapp")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'returns an empty list of app instances states' do
      app_instances_states = @app.find_app_instances_states(nil)
      app_instances_states.should be_empty
    end

    it 'raises an AuthError exception when stopping an app' do
      expect {
        app_info = @app.stop("newapp")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when starting an app' do
      expect {
        app_info = @app.start("newapp")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when restarting an app' do
      expect {
        app_info = @app.restart("newapp")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when setting app number of instances' do
      expect {
        updated = @app.set_instances("newapp", "1")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when setting app memory size' do
      expect {
        updated = @app.set_memsize("newapp", "128")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when setting an app var' do
      expect {
        var_exists = @app.set_var("newapp", "var-mock", "value-mock")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when unsetting an app var' do
      expect {
        var_deleted = @app.unset_var("newapp", "var-mock")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when binding a service' do
      expect {
        binded = @app.bind_service("newapp", "redis-mock")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when unbinding a service' do
      expect {
        unbinded = @app.unbind_service("newapp", "redis-mock")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when mapping a url' do
      expect {
        app_url = @app.map_url("newapp", "http://app-mock.vcap.me")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when unmapping a url' do
      expect {
        app_url = @app.unmap_url("newapp", "http://newapp.vcap.me")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when viewing a file' do
      expect {
        files = @app.view_file("newapp", "/", "0")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when deleting an app' do
      expect {
        deleted = @app.delete("newapp")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end
  end

  context "with a user logged in" do
    before(:all) do
      VCR.use_cassette("models/logged/client", :record => :new_episodes) do
        cf_client = cloudfoundry_client_user_logged(CloudFoundry::Client::DEFAULT_TARGET)
        @app = App.new(cf_client)
        @service = Service.new(cf_client)
      end
    end

    use_vcr_cassette "models/logged/app", :record => :new_episodes

    it 'raises an exception when creating an app with a blank name' do
      expect {
        created = @app.create("", "1", "64", "newapp.vcap.me", "node", "node", "")
      }.to raise_exception
    end

    it 'raises an exception when creating an app with an invalid name' do
      expect {
        created = @app.create("new name", "1", "64", "newapp.vcap.me", "node", "node", "")
      }.to raise_exception
    end

    it 'raises an exception when creating an app with a blank number of instances' do
      expect {
        created = @app.create("newapp", "", "64", "newapp.vcap.me", "node", "node", "")
      }.to raise_exception
    end

    it 'raises an exception when creating an app with a non-numeric number of instances' do
      expect {
        created = @app.create("newapp", "A", "64", "newapp.vcap.me", "node", "node", "")
      }.to raise_exception
    end

    it 'raises an exception when creating an app with a number of instances <= 0' do
      expect {
        created = @app.create("newapp", "0", "64", "newapp.vcap.me", "node", "node", "")
      }.to raise_exception
    end

    it 'raises an exception when creating an app with a blank memory size' do
      expect {
        created = @app.create("newapp", "1", "", "newapp.vcap.me", "node", "node", "")
      }.to raise_exception
    end

    it 'raises an exception when creating an app with a non-numeric memory size' do
      expect {
        created = @app.create("newapp", "1", "A", "newapp.vcap.me", "node", "node", "")
      }.to raise_exception
    end

    it 'raises an exception when creating an app which exceeds account capacity due a high number of instances' do
      expect {
        created = @app.create("newapp", "1000000", "64", "newapp.vcap.me", "node", "node", "")
      }.to raise_exception
    end

    it 'raises an exception when creating an app which exceeds account capacity due a high memory size' do
      expect {
        created = @app.create("newapp", "1", "64000000", "newapp.vcap.me", "node", "node", "")
      }.to raise_exception
    end

    it 'raises an exception when creating an app with a blank url' do
      expect {
        created = @app.create("newapp", "1", "64", "", "node", "node", "")
      }.to raise_exception
    end

    it 'raises an exception when creating an app with a blank framework' do
      expect {
        created = @app.create("newapp", "1", "64", "newapp.vcap.me", "", "node", "")
      }.to raise_exception
    end

    it 'raises an exception when creating an app with a blank runtime' do
      expect {
        created = @app.create("newapp", "1", "64", "newapp.vcap.me", "node", "", "")
      }.to raise_exception
    end

    it 'raises an exception when creating an app with an invalid framework' do
      expect {
        created = @app.create("newapp", "1", "64", "newapp.vcap.me", "noframework", "node", "")
      }.to raise_exception
    end

    it 'raises an exception when creating an app with an invalid runtime' do
      expect {
        created = @app.create("newapp", "1", "64", "newapp.vcap.me", "node", "noruntime", "")
      }.to raise_exception
    end

    it 'raises an exception when creating an app with an invalid combination of framework and runtime' do
      expect {
        created = @app.create("newapp", "1", "64", "newapp.vcap.me", "node", "java", "")
      }.to raise_exception
    end

    it 'raises an exception when creating an app with an invalid service' do
      expect {
        created = @app.create("newapp", "1", "64", "newapp.vcap.me", "node", "node", "noservice")
      }.to raise_exception
    end

    it 'can create a new app' do
      VCR.use_cassette("models/logged/app_create_action", :record => :new_episodes, :exclusive => true) do
        created = @app.create("newapp", "1", "64", "newapp.vcap.me", "node", "node", "")
        created.should be_true
      end
    end

    it 'raises an exception when creating an app that already exists' do
      VCR.use_cassette("models/logged/app_create_duplicate_action", :record => :new_episodes, :exclusive => true) do
        expect {
          created = @app.create("newapp", "1", "64", "newapp.vcap.me", "node", "node", "")
        }.to raise_exception
      end
    end

    it 'returns a proper list of all apps' do
      apps = @app.find_all_apps()
      apps.should have_at_least(1).items
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

    it 'returns info about an app' do
      app_info = @app.find("newapp")
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

    it 'raises an exception when looking for an app with a blank name' do
      expect {
        app_info = @app.find("")
      }.to raise_exception
    end

    it 'raises a NotFound exception when looking for an app that does not exists' do
      expect {
        app_info = @app.find("noapp")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'returns a proper list of app instances' do
      app_instances = @app.find_app_instances("newapp")
      app_instances.should be_empty
    end

    it 'raises a NotFound exception when looking for instances of an app with a blank name' do
      expect {
        app_instances = @app.find_app_instances("")
      }.to raise_exception
    end

    it 'raises a NotFound exception when looking for instances of an app that does not exists' do
      expect {
        app_instances = @app.find_app_instances("noapp")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'returns an empty list of app crashes' do
      app_crashes = @app.find_app_crashes("newapp")
      app_crashes.should be_empty
    end

    it 'raises a NotFound exception when looking for crashes of an app with a blank name' do
      expect {
        app_crashes = @app.find_app_app_crashes("")
      }.to raise_exception
    end

    it 'raises a NotFound exception when looking for crashes of an app that does not exists' do
      expect {
        app_crashes = @app.find_app_crashes("noapp")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'returns a proper list of states if the app is started' do
      app_info = @app.find("newapp")
      app_states = @app.find_app_instances_states(app_info)
      app_states.should_not be_empty
    end

    it 'can stop an app' do
      # TODO
      # updated = @app.stop("newapp")
    end

    it 'raises an exception when stopping an app with a blank name' do
      expect {
        updated = @app.stop("")
      }.to raise_exception
    end

    it 'raises a NotFound exception when stopping an app that does not exists' do
      expect {
        updated = @app.stop("noapp")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'can start an app' do
      # TODO
      # updated = @app.start("newapp")
    end

    it 'raises an exception when starting an app with a blank name' do
      expect {
        updated = @app.start("")
      }.to raise_exception
    end

    it 'raises a NotFound exception when starting an app that does not exists' do
      expect {
        updated = @app.start("noapp")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'can restart an app' do
      # TODO
      # updated = @app.restart("newapp")
    end

    it 'raises an exception when restarting an app with a blank name' do
      expect {
        updated = @app.restart("")
      }.to raise_exception
    end

    it 'raises a NotFound exception when restarting an app that does not exists' do
      expect {
        updated = @app.restart("noapp")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'can set number of instances' do
      VCR.use_cassette("models/logged/app_set_instances_action", :record => :new_episodes, :exclusive => true) do
        updated = @app.set_instances("newapp", "5")
        updated.should be_true
      end
    end

    it 'raises an exception when setting number of instances for an app with blank name' do
      expect {
        updated = @app.set_instances("", "1")
      }.to raise_exception
    end

    it 'raises an exception when setting a blank number of instances for an app' do
      expect {
        updated = @app.set_instances("newapp", "")
      }.to raise_exception
    end

    it 'raises an exception when setting a non-numeric instances for an app' do
      expect {
        updated = @app.set_instances("newapp", "A")
      }.to raise_exception
    end

    it 'raises an exception when setting 0 instances for an app' do
      expect {
        updated = @app.set_instances("newapp", "0")
      }.to raise_exception
    end

    it 'raises an exception when setting a number instances beyond limits for an app' do
      expect {
        updated = @app.set_instances("newapp", "1000000000000")
      }.to raise_exception
    end

    it 'raises a NotFound exception setting number of instances for an app that does not exists' do
      expect {
        updated = @app.set_instances("noapp", "1")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'raises an AuthError exception when setting app memory size' do
      VCR.use_cassette("models/logged/app_set_memory_action", :record => :new_episodes, :exclusive => true) do
        updated = @app.set_memsize("newapp", "128")
        updated.should be_true
      end
    end

    it 'raises an exception when setting memory size for an app with blank name' do
      expect {
        updated = @app.set_memsize("", "128")
      }.to raise_exception
    end

    it 'raises an exception when setting a blank memory size for an app' do
      expect {
        updated = @app.set_memsize("newapp", "")
      }.to raise_exception
    end

    it 'raises an exception when setting a non-numeric memory size for an app' do
      expect {
        updated = @app.set_memsize("newapp", "A")
      }.to raise_exception
    end

    it 'raises an exception when setting memory size beyond limits for an app' do
      expect {
        updated = @app.set_memsize("newapp", "1000000000000")
      }.to raise_exception
    end

    it 'raises a NotFound exception setting memory size for an app that does not exists' do
      expect {
        updated = @app.set_memsize("noapp", "128")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'can set a var' do
      VCR.use_cassette("models/logged/app_set_var_action", :record => :new_episodes, :exclusive => true) do
        var_exists = @app.set_var("newapp", "var-mock", "value-mock")
        var_exists.should be_nil
      end
    end

    it 'raises an exception when setting a var for an app with a blank name' do
      expect {
        var_exists = @app.set_var("", "var-mock", "value-mock")
      }.to raise_exception
    end

    it 'raises an exception when setting a blank var for an app' do
      expect {
        var_exists = @app.set_var("newapp", "", "value-mock")
      }.to raise_exception
    end

    it 'raises an exception when setting an invalid var name for an app' do
      expect {
        var_exists = @app.set_var("newapp", "var mock", "value-mock")
      }.to raise_exception
    end

    it 'raises a NotFound exception when setting a var if the app does not exists' do
      expect {
        var_exists = @app.set_var("noapp", "var-mock", "value-mock")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'can modify a var' do
      VCR.use_cassette("models/logged/app_modify_var_action", :record => :new_episodes, :exclusive => true) do
        var_exists = @app.set_var("newapp", "var-mock", "value-mock-2")
        var_exists.should_not be_empty
      end
    end

    it 'can unset a var' do
      VCR.use_cassette("models/logged/app_unset_var_action", :record => :new_episodes, :exclusive => true) do
        var_deleted = @app.unset_var("newapp", "var-mock")
        var_deleted.should be_true
      end
    end

    it 'raises an exception when unsetting a var for an app with a blank name' do
      expect {
        var_deleted = @app.unset_var("", "var-mock")
      }.to raise_exception
    end

    it 'raises an exception when setting a blank var for an app' do
      expect {
        var_deleted = @app.unset_var("newapp", "")
      }.to raise_exception
    end

    it 'raises an exception when unsetting a var that is not set' do
      expect {
        var_deleted = @app.unset_var("newapp", "novar")
      }.to raise_exception
    end

    it 'raises a NotFound exception when unsetting a var if the app does not exists' do
      expect {
        var_deleted = @app.unset_var("noapp", "var-mock")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'can bind a service' do
      VCR.use_cassette("models/logged/app_bind_service_action", :record => :new_episodes, :exclusive => true) do
        created = @service.create("redis-mock", "redis")
        binded = @app.bind_service("newapp", "redis-mock")
        binded.should be_true
      end
    end

    it 'raises an exception when binding a service for an app with a blank name' do
      expect {
        binded = @app.bind_service("", "redis-mock")
      }.to raise_exception
    end

    it 'raises an exception when binding a blank service' do
      expect {
        binded = @app.bind_service("newapp", "")
      }.to raise_exception
    end

    it 'raises an exception when binding a service already binded' do
      VCR.use_cassette("models/logged/app_bind_service_binded_action", :record => :new_episodes, :exclusive => true) do
        expect {
          binded = @app.bind_service("newapp", "redis-mock")
        }.to raise_exception
      end
    end

    it 'raises a NotFound exception when binding a service if the app does not exists' do
      expect {
        binded = @app.bind_service("noapp", "redis-mock")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'raises a NotFound exception when binding a service that does not exists' do
      VCR.use_cassette("models/logged/app_bind_invalid_service_action", :record => :new_episodes, :exclusive => true) do
        expect {
          binded = @app.bind_service("newapp", "no-service")
        }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
      end
    end

    it 'can unbind a service' do
      VCR.use_cassette("models/logged/app_unbind_service_action", :record => :new_episodes, :exclusive => true) do
        unbinded = @app.unbind_service("newapp", "redis-mock")
        unbinded.should be_true
        deleted = @service.delete("redis-mock")
      end
    end

    it 'raises an exception when unbinding a service from an app with a blank name' do
      expect {
        unbinded = @app.unbind_service("", "redis-mock")
      }.to raise_exception
    end

    it 'raises an exception when unbinding a blank service' do
      expect {
        unbinded = @app.unbind_service("newapp", "")
      }.to raise_exception
    end

    it 'raises an exception when unbinding a service that is not binded' do
      expect {
        @app.unbind_service("newapp", "no-service")
      }.to raise_exception
    end

    it 'raises a NotFound exception when unbinding a service if the app does not exists' do
      expect {
        @app.unbind_service("noapp", "redis-mock")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'can map a url' do
      VCR.use_cassette("models/logged/app_map_url_action", :record => :new_episodes, :exclusive => true) do
        app_url = @app.map_url("newapp", "http://newapp2.vcap.me")
        app_url.should_not be_empty
      end
    end

    it 'raises an exception when mapping a url for an app with a blank name' do
      expect {
        app_url = @app.map_url("", "http://newapp2.vcap.me")
      }.to raise_exception
    end

    it 'raises an exception when mapping a blank url' do
      expect {
        app_url = @app.map_url("newapp", "")
      }.to raise_exception
    end

    it 'raises an exception when mapping a url that is already mapped' do
      VCR.use_cassette("models/logged/app_map_url_mapped_action", :record => :new_episodes, :exclusive => true) do
        expect {
          app_url = @app.map_url("newapp", "http://newapp2.vcap.me")
        }.to raise_exception
      end
    end

    it 'raises a NotFound exception when mapping a url if the app does not exists' do
      expect {
        app_url = @app.map_url("noapp", "http://noapp.vcap.me")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'can unmap a url' do
      VCR.use_cassette("models/logged/app_unmap_url_action", :record => :new_episodes, :exclusive => true) do
        app_url = @app.unmap_url("newapp", "http://newapp2.vcap.me")
      end
    end

    it 'raises an exception when unmapping a url for an app with a blank name' do
      expect {
        app_url = @app.unmap_url("", "http://newapp2.vcap.me")
      }.to raise_exception
    end

    it 'raises an exception when unmapping a blank url' do
      expect {
        app_url = @app.unmap_url("newapp", "")
      }.to raise_exception
    end

    it 'raises an exception when unmapping a url that is not mapped' do
      expect {
        app_url = @app.unmap_url("newapp", "http://no-url.vcap.me")
      }.to raise_exception
    end

    it 'raises a NotFound exception when unmapping a url if the app does not exists' do
      expect {
        app_url = @app.unmap_url("noapp", "http://newapp2.vcap.me")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'raises a BadRequest exception when viewing files of a stopped app' do
      expect {
        files = @app.view_file("newapp", "/", 0)
      }.to raise_exception(CloudFoundry::Client::Exception::BadRequest)
    end

    it 'raises an exception when viewing files of an app with a blank name' do
      expect {
        files = @app.view_file("", "/", 0)
      }.to raise_exception
    end

    it 'raises an exception when viewing files of an app from a blank path' do
      expect {
        files = @app.view_file("newapp", "", 0)
      }.to raise_exception
    end

    it 'raises a NotFound exception when viewing files of an app that does not exists' do
      expect {
        files = @app.view_file("noapp", "/", 0)
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'can delete an app' do
      deleted = @app.delete("newapp")
      deleted.should be_true
    end

    it 'raises an exception when deleting an app with a blank name' do
      expect {
        deleted = @app.delete("")
      }.to raise_exception
    end

    it 'raises a NotFound exception when deleting an app that does not exists' do
      expect {
        deleted = @app.delete("noapp")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end
  end
end