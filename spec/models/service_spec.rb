require 'spec_helper'

describe Service do
  include CfConnectionHelper

  context 'without a user logged in' do
    before(:all) do
      VCR.use_cassette("models/no_logged/client", :record => :new_episodes) do
        cf_client = cloudfoundry_client(CloudFoundry::Client::DEFAULT_TARGET)
        @service = Service.new(cf_client)
      end
    end

    use_vcr_cassette "models/no_logged/service", :record => :new_episodes

    it 'raises an AuthError exception when creating a provisioned service' do
      expect {
        created = @service.create("fakeservice", "redis")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when looking for all provisioned services' do
      expect {
        services = @service.find_all_services()
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when looking for a provisioned service' do
      expect {
        service_info = @service.find("fakeservice")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when deleting a provisioned service' do
      expect {
        deleted = @service.delete("fakeservice")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end
  end

  context 'with a user logged in' do
    before(:all) do
      VCR.use_cassette("models/logged/client", :record => :new_episodes) do
        cf_client = cloudfoundry_client_user_logged(CloudFoundry::Client::DEFAULT_TARGET)
        @service = Service.new(cf_client)
      end
    end

    use_vcr_cassette "models/logged/service", :record => :new_episodes

    it 'raises an exception when creating a provisioned service with a blank email' do
      expect {
        created = @service.create("", "redis")
      }.to raise_exception(I18n.t('services.model.name_blank'))
    end

    it 'raises an exception when creating a provisioned service with an invalid name' do
      expect {
        created = @service.create("fakes ervice", "redis")
      }.to raise_exception(I18n.t('services.model.name_invalid', :name => "fakes ervice"))
    end

    it 'raises an exception when creating a provisioned service with a blank system service' do
      expect {
        created = @service.create("fakeservice", "")
      }.to raise_exception(I18n.t('services.model.ss_blank'))
    end

    it 'raises a BadParams exception when creating a provisioned service with an invalid system service' do
      expect {
        created = @service.create("fakeservice", "noservice")
      }.to raise_exception(CloudFoundry::Client::Exception::BadParams)
    end

    it 'can create a provisioned service' do
      created = @service.create("fakeservice", "redis")
      created.should be_true
    end

    it 'can retrieve a proper list of provisioned services' do
      services = @service.find_all_services()
      services.should have_at_least(1).items
      service_info = services.first
      service_info.should have_key :name
      service_info.should have_key :type
      service_info.should have_key :vendor
      service_info.should have_key :version
      service_info.should have_key :tier
      service_info.should have_key :properties
      service_info.should have_key :meta
    end

    it 'raises an exception when retrieving info about a provisioned service with a blank name' do
      expect {
        service_info = @service.find("")
      }.to raise_exception(I18n.t('services.model.name_blank'))
    end

    it 'can retrieve info about a provisioned service' do
      service_info = @service.find("fakeservice")
      service_info.should have_key :name
      service_info[:name].should eql("fakeservice")
      service_info.should have_key :type
      service_info.should have_key :vendor
      service_info.should have_key :version
      service_info.should have_key :tier
      service_info.should have_key :properties
      service_info.should have_key :meta
    end

    it 'raises an NotFound exception when retrieving info about a provisioned service that does not exists' do
      expect {
        service_info = @service.find("noservice")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end

    it 'raises an exception when deleting a provisioned service with a blank name' do
      expect {
        deleted = @service.delete("")
      }.to raise_exception(I18n.t('services.model.name_blank'))
    end

    it 'can delete a provisioned service' do
      deleted = @service.delete("fakeservice")
      deleted.should be_true
    end

    it 'raises an NotFound exception when deleting a provisioned service that does not exists' do
      expect {
        deleted = @service.delete("noservice")
      }.to raise_exception(CloudFoundry::Client::Exception::NotFound)
    end
  end
end