require "spec_helper"

describe SessionsController do
  describe "routing" do
    it "routes to #index" do
      get("/login").should route_to("sessions#new")
    end

    it "routes to #create" do
      post("/login").should route_to("sessions#create")
    end

    it "routes to #destroy" do
      get("/logout").should route_to("sessions#destroy")
    end
  end
end