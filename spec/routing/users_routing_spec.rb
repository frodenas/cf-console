require "spec_helper"

describe UsersController do
  describe "routing" do
    it "routes to #index" do
      get("/users").should route_to("users#index")
    end

    it "routes to #create" do
      post("/users").should route_to("users#create")
    end

    it "routes to #delete" do
      delete("/users/frodenas").should route_to("users#delete", :name => "frodenas")
    end
  end
end