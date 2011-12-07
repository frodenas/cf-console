require 'spec_helper'

describe Service do
  include CfConnectionHelper

  context "without a user logged in" do
    before(:all) do
      VCR.use_cassette("models/no_logged/client", :record => :new_episodes) do
        cf_client = cloudfoundry_client(CloudFoundry::Client::DEFAULT_TARGET)
        @service = Service.new(cf_client)
      end
    end

    use_vcr_cassette "models/no_logged/service", :record => :new_episodes

    it 'raises an AuthError exception when creating a provisioned service' do
      expect {
        created = @service.create("redis-mock", "redis")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when looking for all provisioned services' do
      expect {
        services = @service.find_all_services()
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when looking for a provisioned service' do
      expect {
        service_info = @service.find("redis-mock")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when deleting a provisioned service' do
      expect {
        deleted = @service.delete("redis-mock")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end
  end

  context "with a user logged in" do
    before(:all) do
      VCR.use_cassette("models/logged/client", :record => :new_episodes) do
        cf_client = cloudfoundry_client_user_logged(CloudFoundry::Client::DEFAULT_TARGET)
        @service = Service.new(cf_client)
      end
    end

    use_vcr_cassette "models/logged/service_create", :record => :new_episodes

    it 'prevents creating a provisioned service when name is blank' do
      expect {
        created = @service.create("", "redis")
      }.to raise_exception
    end

    it 'prevents creating a provisioned service with an invalid name' do
      expect {
        created = @service.create("redis mock", "redis")
      }.to raise_exception
    end

    it 'prevents creating a provisioned service when system service is blank' do
      expect {
        created = @service.create("redis-mock", "")
      }.to raise_exception
    end

    it 'prevents creating a provisioned service with an invalid system service' do
      expect {
        created = @service.create("redis-mock", "redis-mock")
      }.to raise_exception
    end

    it 'can create a provisioned service' do
      VCR.use_cassette("models/logged/service_create_action", :record => :new_episodes, :exclusive => true) do
        created = @service.create("redis-mock", "redis")
        created.should be_true
      end
    end

    it 'returns a proper list of provisioned services' do
      services = @service.find_all_services()
      services.should have_at_least(1).items
      service_info = services.first
      service_info.should have_key :type
      service_info.should have_key :vendor
      service_info.should have_key :name
      service_info.should have_key :version
      service_info.should have_key :meta
      service_info.should have_key :properties
      service_info.should have_key :tier
    end

    it 'prevents retrieving info about a provisioned service when name is blank' do
      expect {
        service_info = @service.find("")
      }.to raise_exception
    end

    it 'returns info about the provisioned service created' do
      service_info = @service.find("redis-mock")
      service_info.should have_key :type
      service_info.should have_key :vendor
      service_info.should have_key :name
      service_info[:name].should eql("redis-mock")
      service_info.should have_key :version
      service_info.should have_key :meta
      service_info.should have_key :properties
      service_info.should have_key :tier
    end

    it 'raises an AuthError exception for a provisioned service that does not exists' do
      expect {
        service_info = @service.find("no-redis-mock")
      }.to raise_exception
    end
  end

  context "with a user logged in" do
    before(:all) do
      VCR.use_cassette("models/logged/client", :record => :new_episodes) do
        cf_client = cloudfoundry_client_user_logged(CloudFoundry::Client::DEFAULT_TARGET)
        @service = Service.new(cf_client)
      end
    end

    use_vcr_cassette "models/logged/service_delete", :record => :new_episodes

    it 'prevents deleting a provisioned service when name is blank' do
      expect {
        deleted = @service.delete("")
      }.to raise_exception
    end

    it 'can delete a provisioned service' do
      VCR.use_cassette("models/logged/service_delete_action", :record => :new_episodes, :exclusive => true) do
        deleted = @service.delete("redis-mock")
        deleted.should be_true
      end
    end

    it 'returns an empty list of provisioned services' do
      services = @service.find_all_services()
      services.should have(0).items
    end

    it 'raises an AuthError exception as provisioned service was deleted' do
      expect {
        service_info = @service.find("redis-mock")
      }.to raise_exception
    end
  end
end