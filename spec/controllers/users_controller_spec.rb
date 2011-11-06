require 'spec_helper'

describe UsersController do
  include CfConnectionHelper

  context "without a user logged in" do
    use_vcr_cassette "controllers/no_logged/users", :record => :new_episodes

    describe "GET index" do
      it "redirects to login page" do
        get :index
        response.should redirect_to("/login")
      end
    end

    describe "POST create" do
      it "redirects to login page" do
        post :create, :email => "fakeuser@vcap.me", :password => "foobar", :vpassword => "foobar"
        response.should redirect_to("/login")
      end
    end

    describe "DELETE delete" do
      it "redirects to login page" do
        delete :delete, :name => Base64.encode64("fakeuser@vcap.me")
        response.should redirect_to("/login")
      end
    end
  end

  context "with a user logged in" do
    before(:each) do
      vmc_set_user_cookies(VMC::DEFAULT_LOCAL_TARGET)
    end

    use_vcr_cassette "controllers/logged/users", :record => :new_episodes

    describe "GET index" do
      it "renders index template with a flash alert" do
        get :index
        flash[:alert].should_not be_empty
        response.code.should eq("200")
        render_template("index")
      end

      it "must not return users info" do
        get :index
        assigns(:users).should be_nil
      end
    end

    describe "POST create" do
      it "redirects to users page with a flash alert" do
        post :create, :email => "fakeuser@vcap.me", :password => "foobar", :vpassword => "foobar"
        flash[:alert].should_not be_empty
        response.should redirect_to("/users")
      end

      it "must not return new user info" do
        post :create, :email => "fakeuser@vcap.me", :password => "foobar", :vpassword => "foobar"
        assigns(:new_user).should be_nil
      end
    end

    describe "DELETE delete" do
      it "redirects to users page with a flash alert" do
        delete :delete, :name => Base64.encode64("fakeuser@vcap.me")
        flash[:alert].should_not be_empty
        response.should redirect_to("/users")
      end
    end
  end

  context "with an admin user logged in" do
    before(:each) do
      vmc_set_admin_cookies(VMC::DEFAULT_LOCAL_TARGET)
    end

    use_vcr_cassette "controllers/admin/users", :record => :new_episodes

    describe "GET index" do
      it "renders index page" do
        get :index
        response.code.should eq("200")
        response.should render_template("index")
      end

      it "assigns users info as @users" do
        get :index
        assigns(:users).should_not be_nil
      end
    end

    describe "POST create" do
      it "redirects to users page with a flash alert when email is blank" do
        post :create, :email => "", :password => "foobar", :vpassword => "foobar"
        flash[:alert].should_not be_empty
        response.should redirect_to("/users")
      end

      it "redirects to users page with a flash alert when password is blank" do
        post :create, :email => "fakeuser@vcap.me", :password => "", :vpassword => "foobar"
        flash[:alert].should_not be_empty
        response.should redirect_to("/users")
      end

      it "redirects to users page with a flash alert when vpassword is blank" do
        post :create, :email => "fakeuser@vcap.me", :password => "foobar", :vpassword => ""
        flash[:alert].should_not be_empty
        response.should redirect_to("/users")
      end

      it "redirects to users page with a flash alert when passwords does not match" do
        post :create, :email => "fakeuser@vcap.me", :password => "foobar-1", :vpassword => "foobar-2"
        flash[:alert].should_not be_empty
        response.should redirect_to("/users")
      end

      it "redirects to users page with a flash notice when user is created" do
        VCR.use_cassette("controllers/admin/users_create_action", :record => :new_episodes, :exclusive => true) do
          post :create, :email => "fakeuser@vcap.me", :password => "foobar", :vpassword => "foobar"
          flash[:notice].should_not be_empty
          flash[:notice].should include("fakeuser@vcap.me")
          response.should redirect_to("/users")
        end
      end

      it "assigns user info as @new_user when user is created" do
        VCR.use_cassette("controllers/admin/users_create_action", :record => :new_episodes, :exclusive => true) do
          post :create, :email => "fakeuser@vcap.me", :password => "foobar", :vpassword => "foobar"
          assigns(:new_user).should_not be_nil
          assigns(:new_user).first[:email].should include("fakeuser@vcap.me")
        end
      end

      it "redirects to users page with a flash alert when user already exists" do
        post :create, :email => "fakeuser@vcap.me", :password => "foobar", :vpassword => "foobar"
        flash[:alert].should_not be_empty
        response.should redirect_to("/users")
      end
    end

    describe "DELETE delete" do
      it "redirects to users page with a flash notice when user is deleted" do
        VCR.use_cassette("controllers/admin/users_delete_action", :record => :new_episodes, :exclusive => true) do
          delete :delete, :name => Base64.encode64("fakeuser@vcap.me")
          flash[:notice].should_not be_empty
          flash[:notice].should include("fakeuser@vcap.me")
          response.should redirect_to("/users")
        end
      end

      it "redirects to users page with a flash notice when user does not exists" do
        delete :delete, :name => Base64.encode64("fakeuser@vcap.me")
        flash[:alert].should_not be_empty
        response.should redirect_to("/users")
      end
    end
  end
end