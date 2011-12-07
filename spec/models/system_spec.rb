require 'spec_helper'

describe System do
  include CfConnectionHelper

  context "without a user logged in" do
    before(:all) do
      VCR.use_cassette("models/no_logged/client", :record => :new_episodes) do
        cf_client = cloudfoundry_client(CloudFoundry::Client::DEFAULT_TARGET)
        @system = System.new(cf_client)
      end
    end

    use_vcr_cassette "models/no_logged/system", :record => :new_episodes

    it 'returns basic account info' do
      account_info = @system.find_account_info()
      account_info.should have_key :name
      account_info.should have_key :build
      account_info.should have_key :support
      account_info.should have_key :version
      account_info.should have_key :description
    end

    it 'returns an empty list of frameworks' do
      frameworks = @system.find_all_frameworks()
      frameworks.should be_empty
    end

    it 'returns an empty list of runtimes' do
      runtimes = @system.find_all_runtimes()
      runtimes.should be_empty
    end

    it 'raises an AuthError exception when looking for all system services' do
      expect {
        system_services = @system.find_all_system_services()
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'returns no available memory' do
      available_memory = @system.find_available_memory()
      available_memory.should be_a_kind_of(Integer)
      available_memory.should eql(0)
    end
  end

  context "with a user logged in" do
    before(:all) do
      VCR.use_cassette("models/logged/client", :record => :new_episodes) do
        cf_client = cloudfoundry_client_user_logged(CloudFoundry::Client::DEFAULT_TARGET)
        @system = System.new(cf_client)
      end
    end

    use_vcr_cassette "models/logged/system", :record => :new_episodes

    it 'returns user account info' do
      account_info = @system.find_account_info()
      account_info.should have_key :name
      account_info.should have_key :build
      account_info.should have_key :support
      account_info.should have_key :version
      account_info.should have_key :description
      account_info.should have_key :user
      account_info.should have_key :usage
      account_info.should have_key :limits
      account_info.should have_key :frameworks
    end

    it 'returns a proper list of frameworks' do
      frameworks = @system.find_all_frameworks()
      frameworks.should have_at_least(1).items
      framework_info = frameworks.first[1]
      framework_info.should have_key :name
      framework_info.should have_key :appservers
      framework_info.should have_key :runtimes
    end

    it 'returns a proper list of runtimes' do
      runtimes = @system.find_all_runtimes()
      runtimes.should have_at_least(1).items
      runtime_info = runtimes.first[1]
      runtime_info.should have_key :name
      runtime_info.should have_key :version
      runtime_info.should have_key :description
    end

    it 'returns a proper list of system services' do
      system_services = @system.find_all_system_services()
      system_services.should have_at_least(1).items
      system_service_info = system_services.first[1].values[0].first[1]
      system_service_info.should have_key :id
      system_service_info.should have_key :type
      system_service_info.should have_key :vendor
      system_service_info.should have_key :version
      system_service_info.should have_key :description
      system_service_info.should have_key :tiers
    end

    it 'returns the user account available memory' do
      available_memory = @system.find_available_memory()
      available_memory.should be_a_kind_of(Integer)
    end
  end
end