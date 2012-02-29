require 'spec_helper'

describe App do
  include CfConnectionHelper

  context 'without a user logged in' do
    before(:all) do
      VCR.use_cassette("models/no_logged/client", :record => :new_episodes) do
        cf_client = cloudfoundry_client(CloudFoundry::Client::DEFAULT_TARGET)
        @app = App.new(cf_client)
      end
    end

    use_vcr_cassette "models/no_logged/app", :record => :new_episodes

    it 'raises an exception when creating an app' do
      expect {
        created = @app.create("fakeapp", "1", "64", "fakeurl.vcap.me", "sinatra", "ruby18", "")
      }.to raise_exception(I18n.t('apps.model.memsize_unavailable'))
    end

    it 'raises an AuthError exception when uploading app bits' do
      expect {
        uploaded = @app.upload_app("fakeapp", spec_fixture("cf-sinatra-sample.zip"))
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when starting an app' do
      expect {
        app_info = @app.start("fakeapp")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when setting app number of instances' do
      expect {
        updated = @app.set_instances("fakeapp", "1")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when setting app memory size' do
      expect {
        updated = @app.set_memsize("fakeapp", "128")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when setting an app var' do
      expect {
        var_exists = @app.set_var("fakeapp", "fakevar", "fakevalue")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when binding a service' do
      expect {
        binded = @app.bind_service("fakeapp", "fakeservice")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when mapping a url' do
      expect {
        app_url = @app.map_url("fakeapp", "http://fakeurl.vcap.me")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
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
        app_info = @app.find("fakeapp")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when looking for app instances' do
      expect {
        app_instances = @app.find_app_instances("fakeapp")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when looking for app crashes' do
      expect {
        app_crashes = @app.find_app_crashes("fakeapp")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'returns an empty list of app instances states' do
      app_instances_states = @app.find_app_instances_states(nil)
      app_instances_states.should be_empty
    end

    it 'raises an AuthError exception when unsetting an app var' do
      expect {
        var_deleted = @app.unset_var("fakeapp", "fakevar")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when unbinding a service' do
      expect {
        unbinded = @app.unbind_service("fakeapp", "fakeservice")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when unmapping a url' do
      expect {
        app_url = @app.unmap_url("fakeapp", "http://fakeurl.vcap.me")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when downloading app bits' do
      expect {
        zipfile = @app.download_app("fakeapp")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when viewing a file' do
      expect {
        files = @app.view_file("fakeapp", "/", "0")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when restarting an app' do
      expect {
        app_info = @app.restart("fakeapp")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when stopping an app' do
      expect {
        app_info = @app.stop("fakeapp")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when stopping an app' do
      expect {
        uploaded = @app.upload_app_from_git("fakeapp", "git://github.com/frodenas/cf-sinatra-sample.git", "master")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when deleting an app' do
      expect {
        deleted = @app.delete("fakeapp")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end
  end

  context 'with a user logged in' do
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
        created = @app.create("", "1", "64", "fakeapp.vcap.me", "sinatra", "ruby18", "")
      }.to raise_exception(I18n.t('apps.model.name_blank'))
    end

    it 'raises an exception when creating an app with an invalid name' do
      expect {
        created = @app.create("fake app", "1", "64", "fakeapp.vcap.me", "sinatra", "ruby18", "")
      }.to raise_exception(I18n.t('apps.model.name_invalid', :name => "fake app"))
    end

    it 'raises an exception when creating an app with a blank number of instances' do
      expect {
        created = @app.create("fakeapp", "", "64", "fakeapp.vcap.me", "sinatra", "ruby18", "")
      }.to raise_exception(I18n.t('apps.model.instances_blank'))
    end

    it 'raises an exception when creating an app with a non-numeric number of instances' do
      expect {
        created = @app.create("fakeapp", "A", "64", "fakeapp.vcap.me", "sinatra", "ruby18", "")
      }.to raise_exception(I18n.t('apps.model.instances_numeric'))
    end

    it 'raises an exception when creating an app with a number of instances < 1' do
      expect {
        created = @app.create("fakeapp", "0", "64", "fakeapp.vcap.me", "sinatra", "ruby18", "")
      }.to raise_exception(I18n.t('apps.model.instances_lt1'))
    end

    it 'raises an exception when creating an app with a blank memory size' do
      expect {
        created = @app.create("fakeapp", "1", "", "fakeapp.vcap.me", "sinatra", "ruby18", "")
      }.to raise_exception(I18n.t('apps.model.memsize_blank'))
    end

    it 'raises an exception when creating an app with a non-numeric memory size' do
      expect {
        created = @app.create("fakeapp", "1", "A", "fakeapp.vcap.me", "sinatra", "ruby18", "")
      }.to raise_exception(I18n.t('apps.model.memsize_numeric'))
    end

    it 'raises an exception when creating an app which exceeds account capacity due a high number of instances' do
      expect {
        created = @app.create("fakeapp", "1000000", "64", "fakeapp.vcap.me", "sinatra", "ruby18", "")
      }.to raise_exception(I18n.t('apps.model.memsize_unavailable'))
    end

    it 'raises an exception when creating an app which exceeds account capacity due a high memory size' do
      expect {
        created = @app.create("fakeapp", "1", "64000000", "fakeapp.vcap.me", "sinatra", "ruby18", "")
      }.to raise_exception(I18n.t('apps.model.memsize_unavailable'))
    end

    it 'raises an exception when creating an app with a blank url' do
      expect {
        created = @app.create("fakeapp", "1", "64", "", "sinatra", "ruby18", "")
      }.to raise_exception(I18n.t('apps.model.url_blank'))
    end

    it 'raises an exception when creating an app with a blank framework' do
      expect {
        created = @app.create("fakeapp", "1", "64", "fakeapp.vcap.me", "", "ruby18", "")
      }.to raise_exception(I18n.t('apps.model.framework_blank'))
    end

    it 'raises an exception when creating an app with a blank runtime' do
      expect {
        created = @app.create("fakeapp", "1", "64", "fakeapp.vcap.me", "sinatra", "", "")
      }.to raise_exception(I18n.t('apps.model.runtime_blank'))
    end

    it 'raises an exception when creating an app with an invalid framework' do
      expect {
        created = @app.create("fakeapp", "1", "64", "fakeapp.vcap.me", "noframework", "ruby18", "")
      }.to raise_exception(I18n.t('apps.model.framework_invalid'))
    end

    it 'raises an exception when creating an app with an invalid runtime' do
      expect {
        created = @app.create("fakeapp", "1", "64", "fakeapp.vcap.me", "sinatra", "noruntime", "")
      }.to raise_exception(I18n.t('apps.model.framework_invalid'))
    end

    it 'raises an exception when creating an app with an invalid combination of framework and runtime' do
      expect {
        created = @app.create("fakeapp", "1", "64", "fakeapp.vcap.me", "sinatra", "java", "")
      }.to raise_exception(I18n.t('apps.model.framework_invalid'))
    end

    it 'raises a NotFound exception when creating an app with an invalid service' do
      expect {
        created = @app.create("fakeapp", "1", "64", "fakeapp.vcap.me", "sinatra", "ruby18", "noservice")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'can create a new app' do
      VCR.use_cassette("models/logged/app_create", :record => :new_episodes, :exclusive => true) do
        created = @app.create("fakeapp", "1", "64", "fakeapp.vcap.me", "sinatra", "ruby18", "")
        created.should be_true
      end
    end

    it 'raises an exception when creating an app that already exists' do
      VCR.use_cassette("models/logged/app_create_already_exists", :record => :new_episodes, :exclusive => true) do
        expect {
          created = @app.create("fakeapp", "1", "64", "fakeapp.vcap.me", "sinatra", "ruby18", "")
        }.to raise_exception(I18n.t('apps.model.already_exists'))
      end
    end

    it 'raises an exception when uploading bits for an app with a blank name' do
      expect {
        uploaded = @app.upload_app("", spec_fixture("cf-sinatra-sample.zip"))
      }.to raise_exception(I18n.t('apps.model.name_blank'))
    end

    it 'raises an exception when uploading bits for an app with a blank zipfile' do
      expect {
        uploaded = @app.upload_app("fakeapp", "")
      }.to raise_exception(I18n.t('apps.model.zipfile_blank'))
    end

    it 'can upload app bits' do
      VCR.use_cassette("models/logged/app_upload", :record => :new_episodes, :exclusive => true) do
        uploaded = @app.upload_app("fakeapp", spec_fixture("cf-sinatra-sample.zip"))
        uploaded.should be_true
      end
    end

    it 'raises an exception when uploading bits for an app that does not exists' do
      expect {
        uploaded = @app.upload_app("noapp", spec_fixture("cf-sinatra-sample.zip"))
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'raises an exception when starting an app with a blank name' do
      expect {
        updated = @app.start("")
      }.to raise_exception(I18n.t('apps.model.name_blank'))
    end

    it 'can start an app' do
      VCR.use_cassette("models/logged/app_start", :record => :new_episodes, :exclusive => true) do
        updated = @app.start("fakeapp")
      end
    end

    it 'raises a NotFound exception when starting an app that does not exists' do
      expect {
        updated = @app.start("noapp")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'raises an exception when setting number of instances for an app with blank name' do
      expect {
        updated = @app.set_instances("", "1")
      }.to raise_exception(I18n.t('apps.model.name_blank'))
    end

    it 'raises an exception when setting a blank number of instances for an app' do
      expect {
        updated = @app.set_instances("fakeapp", "")
      }.to raise_exception(I18n.t('apps.model.instances_blank'))
    end

    it 'raises an exception when setting a non-numeric instances for an app' do
      expect {
        updated = @app.set_instances("fakeapp", "A")
      }.to raise_exception(I18n.t('apps.model.instances_numeric'))
    end

    it 'raises an exception when setting 0 instances for an app' do
      expect {
        updated = @app.set_instances("fakeapp", "0")
      }.to raise_exception(I18n.t('apps.model.instances_lt1'))
    end

    it 'raises an exception when setting a number instances beyond limits for an app' do
      VCR.use_cassette("models/logged/app_set_instances_limit", :record => :new_episodes, :exclusive => true) do
        expect {
          updated = @app.set_instances("fakeapp", "1000000000000")
        }.to raise_exception(I18n.t('apps.model.memsize_unavailable'))
      end
    end

    it 'can set number of instances' do
      VCR.use_cassette("models/logged/app_set_instances", :record => :new_episodes, :exclusive => true) do
        updated = @app.set_instances("fakeapp", "5")
        updated.should be_true
      end
    end

    it 'raises a NotFound exception setting number of instances for an app that does not exists' do
      expect {
        updated = @app.set_instances("noapp", "1")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'raises an exception when setting memory size for an app with blank name' do
      expect {
        updated = @app.set_memsize("", "128")
      }.to raise_exception(I18n.t('apps.model.name_blank'))
    end

    it 'raises an exception when setting a blank memory size for an app' do
      expect {
        updated = @app.set_memsize("fakeapp", "")
      }.to raise_exception(I18n.t('apps.model.memsize_blank'))
    end

    it 'raises an exception when setting a non-numeric memory size for an app' do
      expect {
        updated = @app.set_memsize("fakeapp", "A")
      }.to raise_exception(I18n.t('apps.model.memsize_numeric'))
    end

    it 'raises an exception when setting memory size beyond limits for an app' do
      VCR.use_cassette("models/logged/app_set_memory", :record => :new_episodes, :exclusive => true) do
        expect {
          updated = @app.set_memsize("fakeapp", "1000000000000")
        }.to raise_exception(I18n.t('apps.model.memsize_unavailable'))
      end
    end

    it 'can set memory size' do
      VCR.use_cassette("models/logged/app_set_memory", :record => :new_episodes, :exclusive => true) do
        updated = @app.set_memsize("fakeapp", "128")
        updated.should be_true
      end
    end

    it 'raises a NotFound exception setting memory size for an app that does not exists' do
      expect {
        updated = @app.set_memsize("noapp", "128")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'raises an exception when setting a var for an app with a blank name' do
      expect {
        var_exists = @app.set_var("", "fakevar", "fakevalue")
      }.to raise_exception(I18n.t('apps.model.name_blank'))
    end

    it 'raises an exception when setting a blank var for an app' do
      expect {
        var_exists = @app.set_var("fakeapp", "", "fakevalue")
      }.to raise_exception(I18n.t('apps.model.envvar_blank'))
    end

    it 'raises an exception when setting an invalid var name for an app' do
      expect {
        var_exists = @app.set_var("fakeapp", "fake var", "fakevalue")
      }.to raise_exception(I18n.t('apps.model.envvar_invalid', :var_name => "fake var"))
    end

    it 'can set a var' do
      VCR.use_cassette("models/logged/app_set_var", :record => :new_episodes, :exclusive => true) do
        var_exists = @app.set_var("fakeapp", "fakevar", "fakevalue")
        var_exists.should be_nil
      end
    end

    it 'raises a NotFound exception when setting a var if the app does not exists' do
      expect {
        var_exists = @app.set_var("noapp", "fakevar", "fakevalue")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'can modify a var' do
      VCR.use_cassette("models/logged/app_modify_var", :record => :new_episodes, :exclusive => true) do
        var_exists = @app.set_var("fakeapp", "fakevar", "fakevalue2")
        var_exists.should_not be_empty
      end
    end

    it 'raises an exception when binding a service for an app with a blank name' do
      expect {
        binded = @app.bind_service("", "fakeservice")
      }.to raise_exception(I18n.t('apps.model.name_blank'))
    end

    it 'raises an exception when binding a blank service' do
      expect {
        binded = @app.bind_service("fakeapp", "")
      }.to raise_exception(I18n.t('apps.model.service_blank'))
    end

    it 'can bind a service' do
      VCR.use_cassette("models/logged/app_bind_service", :record => :new_episodes, :exclusive => true) do
        created = @service.create("fakeservice", "redis")
        binded = @app.bind_service("fakeapp", "fakeservice")
        binded.should be_true
      end
    end

    it 'raises an exception when binding a service already binded' do
      VCR.use_cassette("models/logged/app_bind_service_already_binded", :record => :new_episodes, :exclusive => true) do
        expect {
          binded = @app.bind_service("fakeapp", "fakeservice")
        }.to raise_exception(I18n.t('apps.model.service_exists', :service => "fakeservice"))
      end
    end

    it 'raises a NotFound exception when binding a service if the app does not exists' do
      expect {
        binded = @app.bind_service("noapp", "fakeservice")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'raises a NotFound exception when binding a service that does not exists' do
      VCR.use_cassette("models/logged/app_bind_service_invalid_service", :record => :new_episodes, :exclusive => true) do
        expect {
          binded = @app.bind_service("fakeapp", "noservice")
        }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
      end
    end

    it 'raises an exception when mapping a url for an app with a blank name' do
      expect {
        app_url = @app.map_url("", "http://fakeapp2.vcap.me")
      }.to raise_exception(I18n.t('apps.model.name_blank'))
    end

    it 'raises an exception when mapping a blank url' do
      expect {
        app_url = @app.map_url("fakeapp", "")
      }.to raise_exception(I18n.t('apps.model.url_blank'))
    end

    it 'can map a url' do
      VCR.use_cassette("models/logged/app_map_url", :record => :new_episodes, :exclusive => true) do
        app_url = @app.map_url("fakeapp", "http://fakeapp2.vcap.me")
        app_url.should_not be_empty
      end
    end

    it 'raises an exception when mapping a url that is already mapped' do
      VCR.use_cassette("models/logged/app_map_url_already_mapped", :record => :new_episodes, :exclusive => true) do
        expect {
          app_url = @app.map_url("fakeapp", "http://fakeapp2.vcap.me")
        }.to raise_exception(I18n.t('apps.model.url_exists', :url => "fakeapp2.vcap.me"))
      end
    end

    it 'raises a NotFound exception when mapping a url if the app does not exists' do
      expect {
        app_url = @app.map_url("noapp", "http://fakeapp.vcap.me")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'returns a proper list of all apps' do
      apps = @app.find_all_apps()
      apps.should have_at_least(1).items
      app_info = apps.first
      app_info.should have_key :name
      app_info.should have_key :staging
      app_info.should have_key :uris
      app_info.should have_key :instances
      app_info.should have_key :runningInstances
      app_info.should have_key :resources
      app_info.should have_key :state
      app_info.should have_key :services
      app_info.should have_key :version
      app_info.should have_key :env
      app_info.should have_key :meta
    end

    it 'returns a proper list of all app states' do
      apps_states = @app.find_all_states()
      apps_states.should have_at_least(1).items
      apps_state = apps_states.first
      apps_state.should have_key :label
      apps_state.should have_key :color
      apps_state.should have_key :data
    end

    it 'raises an exception when looking for an app with a blank name' do
      expect {
        app_info = @app.find("")
      }.to raise_exception(I18n.t('apps.model.name_blank'))
    end

    it 'returns info about an app' do
      VCR.use_cassette("models/logged/app_find", :record => :new_episodes, :exclusive => true) do
        app_info = @app.find("fakeapp")
        app_info.should have_key :name
        app_info.should have_key :staging
        app_info.should have_key :uris
        app_info.should have_key :instances
        app_info.should have_key :runningInstances
        app_info.should have_key :resources
        app_info.should have_key :state
        app_info.should have_key :services
        app_info.should have_key :version
        app_info.should have_key :env
        app_info.should have_key :meta
        app_info.should have_key :instances_info
        app_info.should have_key :crashes
        app_info.should have_key :instances_states
      end
    end

    it 'raises a NotFound exception when looking for an app that does not exists' do
      expect {
        app_info = @app.find("noapp")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'raises an exception when looking for instances of an app with a blank name' do
      expect {
        app_instances = @app.find_app_instances("")
      }.to raise_exception(I18n.t('apps.model.name_blank'))
    end

    it 'returns a proper list of app instances' do
      VCR.use_cassette("models/logged/app_find", :record => :new_episodes, :exclusive => true) do
        app_instances = @app.find_app_instances("fakeapp")
        app_instances.should have_at_least(1).items
        app_instance = app_instances.first
        app_instance.should have_key :instance
        app_instance.should have_key :state
        app_instance.should have_key :stats
      end
    end

    it 'raises a NotFound exception when looking for instances of an app that does not exists' do
      expect {
        app_instances = @app.find_app_instances("noapp")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'raises an exception when looking for crashes of an app with a blank name' do
      expect {
        app_crashes = @app.find_app_crashes("")
      }.to raise_exception(I18n.t('apps.model.name_blank'))
    end

    it 'returns a proper list of app crashes' do
      VCR.use_cassette("models/logged/app_find", :record => :new_episodes, :exclusive => true) do
        app_crashes = @app.find_app_crashes("fakeapp")
        app_crashes.should be_empty
      end
    end

    it 'raises a NotFound exception when looking for crashes of an app that does not exists' do
      expect {
        app_crashes = @app.find_app_crashes("noapp")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'returns a proper list of app instances states' do
      VCR.use_cassette("models/logged/app_find", :record => :new_episodes, :exclusive => true) do
        app_info = @app.find("fakeapp")
        app_instances_states = @app.find_app_instances_states(app_info)
        app_instances_states.should_not be_empty
      end
    end

    it 'returns an empty list of app instances states if the app does not exists' do
      app_instances_states = @app.find_app_instances_states(nil)
      app_instances_states.should be_empty
    end

    it 'raises an exception when unsetting a var for an app with a blank name' do
      expect {
        var_deleted = @app.unset_var("", "fakevar")
      }.to raise_exception(I18n.t('apps.model.name_blank'))
    end

    it 'raises an exception when unsetting a blank var for an app' do
      expect {
        var_deleted = @app.unset_var("fakeapp", "")
      }.to raise_exception(I18n.t('apps.model.envvar_blank'))
    end

    it 'can unset a var' do
      VCR.use_cassette("models/logged/app_unset_var", :record => :new_episodes, :exclusive => true) do
        var_deleted = @app.unset_var("fakeapp", "fakevar")
        var_deleted.should be_true
      end
    end

    it 'raises an exception when unsetting a var that is not set' do
      VCR.use_cassette("models/logged/app_unset_var_not_set", :record => :new_episodes, :exclusive => true) do
        expect {
          var_deleted = @app.unset_var("fakeapp", "novar")
        }.to raise_exception(I18n.t('apps.model.envvar_not_set', :var_name => "novar"))
      end
    end

    it 'raises a NotFound exception when unsetting a var if the app does not exists' do
      expect {
        var_deleted = @app.unset_var("noapp", "fakevar")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end


    it 'raises an exception when unbinding a service from an app with a blank name' do
      expect {
        unbinded = @app.unbind_service("", "fakeservice")
      }.to raise_exception(I18n.t('apps.model.name_blank'))
    end

    it 'raises an exception when unbinding a blank service' do
      expect {
        unbinded = @app.unbind_service("fakeapp", "")
      }.to raise_exception(I18n.t('apps.model.service_blank'))
    end

    it 'can unbind a service' do
      VCR.use_cassette("models/logged/app_unbind_service", :record => :new_episodes, :exclusive => true) do
        unbinded = @app.unbind_service("fakeapp", "fakeservice")
        unbinded.should be_true
        deleted = @service.delete("fakeservice")
      end
    end

    it 'raises an exception when unbinding a service that is not binded' do
      VCR.use_cassette("models/logged/app_unbind_service", :record => :new_episodes, :exclusive => true) do
        expect {
          @app.unbind_service("fakeapp", "noservice")
        }.to raise_exception(I18n.t('apps.model.service_not_binded', :service => "noservice"))
      end
    end

    it 'raises a NotFound exception when unbinding a service if the app does not exists' do
      expect {
        @app.unbind_service("noapp", "fakeservice")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'raises an exception when unmapping a url for an app with a blank name' do
      expect {
        app_url = @app.unmap_url("", "http://fakeapp2.vcap.me")
      }.to raise_exception(I18n.t('apps.model.name_blank'))
    end

    it 'raises an exception when unmapping a blank url' do
      expect {
        app_url = @app.unmap_url("fakeapp", "")
      }.to raise_exception(I18n.t('apps.model.url_blank'))
    end

    it 'can unmap a url' do
      VCR.use_cassette("models/logged/app_unmap_url", :record => :new_episodes, :exclusive => true) do
        app_url = @app.unmap_url("fakeapp", "http://fakeapp2.vcap.me")
      end
    end

    it 'raises an exception when unmapping a url that is not mapped' do
      VCR.use_cassette("models/logged/app_unmap_url_not_mapped", :record => :new_episodes, :exclusive => true) do
        expect {
          app_url = @app.unmap_url("fakeapp", "http://no-url.vcap.me")
        }.to raise_exception(I18n.t('apps.model.url_not_mapped', :url => "no-url.vcap.me"))
      end
    end

    it 'raises a NotFound exception when unmapping a url if the app does not exists' do
      expect {
        app_url = @app.unmap_url("noapp", "http://fakeapp2.vcap.me")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'raises an exception when downloading app bits of an app with a blank name' do
      expect {
        files = @app.download_app("")
      }.to raise_exception(I18n.t('apps.model.name_blank'))
    end

    it 'can download app bits' do
      VCR.use_cassette("models/logged/app_download", :record => :new_episodes, :exclusive => true) do
        zipfile = @app.download_app("fakeapp")
        zipfile.should_not be_empty
      end
    end

    it 'raises a NotFound exception when downloading app bits of an app that does not exists' do
      expect {
        files = @app.download_app("noapp")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'raises an exception when viewing files of an app with a blank name' do
      expect {
        files = @app.view_file("", "/", 0)
      }.to raise_exception(I18n.t('apps.model.name_blank'))
    end

    it 'raises an exception when viewing files of an app from a blank path' do
      expect {
        files = @app.view_file("fakeapp", "", 0)
      }.to raise_exception(I18n.t('apps.model.path_blank'))
    end

    it 'can view files' do
      files = @app.view_file("fakeapp", "/", 0)
      files.should_not be_empty
    end

    it 'raises a NotFound exception when viewing files of an app that does not exists' do
      expect {
        files = @app.view_file("noapp", "/", 0)
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'raises an exception when restarting an app with a blank name' do
      expect {
        updated = @app.restart("")
      }.to raise_exception(I18n.t('apps.model.name_blank'))
    end

    it 'can restart an app' do
      VCR.use_cassette("models/logged/app_restart", :record => :new_episodes, :exclusive => true) do
        updated = @app.restart("fakeapp")
      end
    end

    it 'raises a NotFound exception when restarting an app that does not exists' do
      expect {
        updated = @app.restart("noapp")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'raises an exception when stopping an app with a blank name' do
      expect {
        updated = @app.stop("")
      }.to raise_exception(I18n.t('apps.model.name_blank'))
    end

    it 'can stop an app' do
      VCR.use_cassette("models/logged/app_stop", :record => :new_episodes, :exclusive => true) do
        updated = @app.stop("fakeapp")
      end
    end

    it 'raises a NotFound exception when stopping an app that does not exists' do
      expect {
        updated = @app.stop("noapp")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'returns info about a stopped app' do
      VCR.use_cassette("models/logged/app_find_stopped", :record => :new_episodes, :exclusive => true) do
        app_info = @app.find("fakeapp")
        app_info.should have_key :name
        app_info.should have_key :staging
        app_info.should have_key :uris
        app_info.should have_key :instances
        app_info.should have_key :runningInstances
        app_info.should have_key :resources
        app_info.should have_key :state
        app_info.should have_key :services
        app_info.should have_key :version
        app_info.should have_key :env
        app_info.should have_key :meta
        app_info.should have_key :instances_info
        app_info.should have_key :crashes
        app_info.should have_key :instances_states
      end
    end

    it 'raises an exception when uploading bits from Git for an app with a blank name' do
      expect {
        uploaded = @app.upload_app_from_git("", "git://github.com/frodenas/cloudfoundry-client.git", "master")
      }.to raise_exception(I18n.t('apps.model.name_blank'))
    end

    it 'raises an exception when uploading bits from Git for an app with an invalid name' do
      expect {
        uploaded = @app.upload_app_from_git("fake app", "git://github.com/frodenas/cloudfoundry-client.git", "master")
      }.to raise_exception(I18n.t('apps.model.name_invalid', :name => "fake app"))
    end

    it 'raises an exception when uploading bits from Git for an app with a blank Git URI' do
      expect {
        uploaded = @app.upload_app_from_git("fakeapp", "", "master")
      }.to raise_exception(I18n.t('apps.model.gitrepo_blank'))
    end

    it 'raises an exception when uploading bits from Git for an app with a blank Git Branch' do
      expect {
        uploaded = @app.upload_app_from_git("fakeapp", "git://github.com/frodenas/cloudfoundry-client.git", "")
      }.to raise_exception(I18n.t('apps.model.gitbranch_blank'))
    end

    it 'can upload app bits from Git' do
      VCR.use_cassette("models/logged/app_upload_from_git", :record => :new_episodes, :exclusive => true) do
        uploaded = @app.upload_app_from_git("fakeapp", "git://github.com/frodenas/cloudfoundry-client.git", "master")
        uploaded.should be_true
      end
    end

    # TODO Fix this test when executed in Travis CI
    #it 'raises an exception when uploading bits from Git and bits did not change' do
      #VCR.use_cassette("models/logged/app_upload_from_git_nofiles", :record => :new_episodes, :exclusive => true) do
        #expect {
          #uploaded = @app.upload_app_from_git("fakeapp", "git://github.com/frodenas/cloudfoundry-client.git", "master")
        #}.to raise_exception(I18n.t('apps.model.no_files'))
      #end
    #end

    it 'raises an exception when uploading bits from Git for an app that does not exists' do
      expect {
        uploaded = @app.upload_app_from_git("noapp", "git://github.com/frodenas/cloudfoundry-client.git", "master")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'raises an exception when starting an app fails' do
      VCR.use_cassette("models/logged/app_start_failed", :record => :new_episodes, :exclusive => true) do
        expect {
          updated = @app.start("fakeapp")
        }.to raise_exception(I18n.t('apps.model.undetermined_state'))
      end
    end

    it 'raises an exception when deleting an app with a blank name' do
      expect {
        deleted = @app.delete("")
      }.to raise_exception(I18n.t('apps.model.name_blank'))
    end

    it 'can delete an app' do
      VCR.use_cassette("models/logged/app_delete", :record => :new_episodes, :exclusive => true) do
        deleted = @app.delete("fakeapp")
        deleted.should be_true
      end
    end

    it 'raises a NotFound exception when deleting an app that does not exists' do
      expect {
        deleted = @app.delete("noapp")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end
  end
end