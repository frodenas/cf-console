require 'spec_helper'

describe User do
  include CfConnectionHelper

  context 'without a user logged in' do
    before(:all) do
      VCR.use_cassette("models/no_logged/client", :record => :new_episodes) do
        cf_client = cloudfoundry_client(CloudFoundry::Client::DEFAULT_TARGET)
        @user = User.new(cf_client)
      end
    end

    use_vcr_cassette "models/no_logged/user", :record => :new_episodes

    it 'can create a user (fakeuser1@vcap.me)' do
      created = @user.create("fakeuser1@vcap.me", "foobar")
      created.should be_true
    end

    it 'raises an AuthError exception when looking for all users' do
      expect {
        users = @user.find_all_users()
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when looking for a user' do
      expect {
        user_info = @user.find("fakeuser1@vcap.me")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when looking for if a user is admin' do
      expect {
        user_is_admin = @user.is_admin?("fakeuser1@vcap.me")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end

    it 'raises an AuthError exception when deleting a user' do
      expect {
        deleted = @user.delete("fakeuser1@vcap.me")
      }.to raise_exception(CloudFoundry::Client::Exception::AuthError)
    end
  end

  context 'with a user logged in' do
    before(:all) do
      VCR.use_cassette("models/logged/client", :record => :new_episodes) do
        cf_client = cloudfoundry_client_user_logged(CloudFoundry::Client::DEFAULT_TARGET)
        @user = User.new(cf_client)
      end
    end

    use_vcr_cassette "models/logged/user", :record => :new_episodes

    it 'can create a user (fakeuser2@vcap.me)' do
      created = @user.create("fakeuser2@vcap.me", "foobar")
      created.should be_true
    end

    it 'raises a Forbidden exception when looking for all users' do
      expect {
        users = @user.find_all_users()
      }.to raise_exception(CloudFoundry::Client::Exception::Forbidden)
    end

    it 'raises a Forbidden exception when looking for a user' do
      expect {
        user_info = @user.find("fakeuser2@vcap.me")
      }.to raise_exception(CloudFoundry::Client::Exception::Forbidden)
    end

    it 'raises a Forbidden exception when looking for if a user is admin' do
      expect {
        user_is_admin = @user.is_admin?("fakeuser2@vcap.me")
      }.to raise_exception(CloudFoundry::Client::Exception::Forbidden)
    end

    it 'raises a Forbidden exception when deleting a user' do
      expect {
        deleted = @user.delete("fakeuser2@vcap.me")
      }.to raise_exception(CloudFoundry::Client::Exception::Forbidden)
    end
  end

  context 'with an admin user logged in' do
    before(:all) do
      VCR.use_cassette("models/admin/client", :record => :new_episodes) do
        cf_client = cloudfoundry_client_admin_logged(CloudFoundry::Client::DEFAULT_TARGET)
        @user = User.new(cf_client)
      end
    end

    use_vcr_cassette "models/admin/user", :record => :new_episodes

    it 'raises an exception when creating a user with a blank email' do
      expect {
        created = @user.create("", "foobar")
      }.to raise_exception(I18n.t('users.model.email_blank'))
    end

    it 'raises an exception when creating a user with a blank password' do
      expect {
        created = @user.create("fakeuser@vcap.me", "")
      }.to raise_exception(I18n.t('users.model.password_blank'))
    end

    it 'can create a user (fakeuser@vcap.me)' do
      created = @user.create("fakeuser@vcap.me", "foobar")
      created.should be_true
    end

    it 'can retrieve a proper list of users' do
      users = @user.find_all_users()
      users.should have_at_least(1).items
      user_info = users.first
      user_info.should have_key :email
      user_info.should have_key :admin
    end

    it 'raises an exception when retrieving info about a user with a blank email' do
      expect {
        user_info = @user.find("")
      }.to raise_exception(I18n.t('users.model.email_blank'))
    end

    it 'can retrieve info about a user' do
      user_info = @user.find("fakeuser@vcap.me")
      user_info.should have_key :email
      user_info[:email].should eql("fakeuser@vcap.me")
      user_info.should have_key :admin
      user_info[:admin].should be_false
    end

    it 'raises a Forbidden exception when retrieving info about a user that does not exists' do
      expect {
        user_info = @user.find("nouser@vcap.me")
      }.to raise_exception(CloudFoundry::Client::Exception::Forbidden)
    end

    it 'raises an exception when asking if a user with a blank email is admin' do
      expect {
        user_is_admin = @user.is_admin?("")
      }.to raise_exception(I18n.t('users.model.email_blank'))
    end

    it 'returns true when asking if an admin user is admin' do
      user_is_admin = @user.is_admin?("admin@vcap.me")
      user_is_admin.should be_true
    end

    it 'returns true when asking if an admin user is admin on a legacy cc' do
      VCR.use_cassette("models/admin/user_legacy_cc", :record => :new_episodes, :exclusive => true) do
        user_is_admin = @user.is_admin?("admin@vcap.me")
        user_is_admin.should be_true
      end
    end

    it 'returns false when asking if a non admin user is admin' do
      user_is_admin = @user.is_admin?("fakeuser@vcap.me")
      user_is_admin.should be_false
    end

    it 'raises a Forbidden exception when asking if a user that does not exists is admin' do
      expect {
        user_is_admin = @user.is_admin?("nouser@vcap.me")
      }.to raise_exception(CloudFoundry::Client::Exception::Forbidden)
    end

    it 'raises an exception when deleting a user with a blank email' do
      expect {
        deleted = @user.delete("")
      }.to raise_exception(I18n.t('users.model.email_blank'))
    end

    it 'can delete a user (fakeuser@vcap.me)' do
      deleted = @user.delete("fakeuser@vcap.me")
      deleted.should be_true
    end

    it 'can delete a user (fakeuser1@vcap.me)' do
      deleted = @user.delete("fakeuser1@vcap.me")
      deleted.should be_true
    end

    it 'can delete a user (fakeuser2@vcap.me)' do
      deleted = @user.delete("fakeuser2@vcap.me")
      deleted.should be_true
    end

    it 'raises a Forbidden exception when deleting a user that does not exists' do
      expect {
        deleted = @user.delete("nouser@vcap.me")
        deleted.should be_true
      }.to raise_exception(CloudFoundry::Client::Exception::Forbidden)
    end
  end
end