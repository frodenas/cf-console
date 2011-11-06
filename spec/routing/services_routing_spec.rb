require "spec_helper"

describe ServicesController do
  describe "routing" do
    it "routes to #index" do
      get("/services").should route_to("services#index")
    end

    it "routes to #create" do
      post("/services").should route_to("services#create")
    end

    it "routes to #delete" do
      delete("/services/mysql").should route_to("services#delete", :name => "mysql")
    end
  end
end