require "spec_helper"

describe SystemController do
  describe "routing" do
    it "routes to #index" do
      get("/system").should route_to("system#index")
    end
  end
end