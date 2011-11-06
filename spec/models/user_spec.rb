require 'spec_helper'

describe User do
  include CfConnectionHelper

  context "without a user logged in" do
    before(:all) do
      VCR.use_cassette("models/no_logged/client", :record => :new_episodes) do
        cf_client = vmc_client(VMC::DEFAULT_LOCAL_TARGET)
        @user = User.new(cf_client)
      end
    end

    use_vcr_cassette "models/no_logged/user", :record => :new_episodes

    it 'raises a TargetError exception when creating a user' do
      # Enable this test only if local_register_only is true in cloud_controller.yml
      #expect {
        #@user.create("fakeuser@vcap.me", "foobar")
      #}.to raise_exception(VMC::Client::TargetError)
    end

    it 'raises an AuthError exception when looking for all users' do
      expect {
        users = @user.find_all_users()
      }.to raise_exception(VMC::Client::AuthError)
    end

    it 'raises an AuthError exception when looking for a user' do
      expect {
        user_info = @user.find("fakeuser@vcap.me")
      }.to raise_exception(VMC::Client::AuthError)
    end

    it 'raises an AuthError exception when looking for if a user is admin' do
      expect {
        user_is_admin = @user.is_admin?("fakeuser@vcap.me")
      }.to raise_exception(VMC::Client::AuthError)
    end

    it 'raises an AuthError exception when deleting a user' do
      expect {
        @user.delete("fakeuser@vcap.me")
      }.to raise_exception(VMC::Client::AuthError)
    end
  end

  context "with a user logged in" do
    before(:all) do
      VCR.use_cassette("models/logged/client", :record => :new_episodes) do
        cf_client = vmc_client_user_logged(VMC::DEFAULT_LOCAL_TARGET)
        @user = User.new(cf_client)
      end
    end

    use_vcr_cassette "models/logged/user", :record => :new_episodes

    it 'raises a TargetError exception when creating a user' do
      # Enable this test only if local_register_only is true in cloud_controller.yml
      #expect {
        #@user.create("fakeuser@vcap.me", "foobar")
      #}.to raise_exception(VMC::Client::TargetError)
    end

    it 'raises a TargetError exception when looking for all users' do
      expect {
        users = @user.find_all_users()
      }.to raise_exception(VMC::Client::TargetError)
    end

    it 'raises a TargetError exception when looking for a user' do
      expect {
        user_info = @user.find("fakeuser@vcap.me")
      }.to raise_exception(VMC::Client::TargetError)
    end

    it 'raises a TargetError exception when looking for if a user is admin' do
      expect {
        user_is_admin = @user.is_admin?("fakeuser@vcap.me")
      }.to raise_exception(VMC::Client::TargetError)
    end

    it 'raises a TargetError exception when deleting a user' do
      expect {
        @user.delete("fakeuser@vcap.me")
      }.to raise_exception(VMC::Client::TargetError)
    end
  end

  context "with an admin user logged in" do
    before(:all) do
      VCR.use_cassette("models/admin/client", :record => :new_episodes) do
        cf_client = vmc_client_admin_logged(VMC::DEFAULT_LOCAL_TARGET)
        @user = User.new(cf_client)
      end
    end

    use_vcr_cassette "models/admin/user_create", :record => :new_episodes

    it 'prevents creating a user when email is blank' do
      expect {
        @user.create("", "foobar")
      }.to raise_exception
    end

    it 'prevents creating a user when password is blank' do
      expect {
        @user.create("fakeuser@vcap.me", "")
      }.to raise_exception
    end

    it 'can create a user' do
      VCR.use_cassette("models/admin/user_create_action", :record => :new_episodes, :exclusive => true) do
        @user.create("fakeuser@vcap.me", "foobar")
        # Check later if user was created
      end
    end

    it 'returns a proper list of users' do
      users = @user.find_all_users()
      users.should have_at_least(1).items
      user_info = users.first
      user_info.should have_key :email
      user_info.should have_key :admin
      user_info.should have_key :apps
    end

    it 'returns info about the user created' do
      user_info = @user.find("fakeuser@vcap.me")
      user_info.should have_key :email
      user_info[:email].should eql("fakeuser@vcap.me")
      user_info.should have_key :admin
      user_info.should have_key :apps
    end

    it 'returns false when asking for a non admin user' do
      user_is_admin = @user.is_admin?("fakeuser@vcap.me")
      user_is_admin.should be_false
    end

    it 'returns nil for a user that does not exists' do
      user_info = @user.find("nouser@vcap.me")
      user_info.should be_nil
    end
  end

  context "with an admin user logged in" do
    before(:all) do
      VCR.use_cassette("models/admin/client", :record => :new_episodes) do
        cf_client = vmc_client_admin_logged(VMC::DEFAULT_LOCAL_TARGET)
        @user = User.new(cf_client)
      end
    end

    use_vcr_cassette "models/admin/user_delete", :record => :new_episodes

    it 'prevents deleting a user when email is blank' do
      expect {
        @user.delete("")
      }.to raise_exception
    end

    it 'can delete a user' do
      VCR.use_cassette("models/admin/user_delete_action", :record => :new_episodes, :exclusive => true) do
        @user.delete("fakeuser@vcap.me")
        # Check later if user was deleted
      end
    end

    it 'returns a proper list of users' do
      users = @user.find_all_users()
      users.should have(2).items
    end

    it 'returns nil as user was deleted' do
      user_info = @user.find("fakeuser@vcap.me")
      user_info.should be_nil
    end
  end
end