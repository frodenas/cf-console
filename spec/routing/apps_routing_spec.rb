require "spec_helper"

describe AppsController do
  describe "routing" do
    it "routes to #index" do
      get("/apps").should route_to("apps#index")
    end

    it "routes to #create" do
      post("/apps").should route_to("apps#create")
    end

    it "routes to #show" do
      get("/app/cf-console").should route_to("apps#show", :name => "cf-console")
    end

    it "routes to #delete" do
      delete("/app/cf-console").should route_to("apps#delete", :name => "cf-console")
    end

    it "routes to #start" do
      put("/app/cf-console/start").should route_to("apps#start", :name => "cf-console")
    end

    it "routes to #stop" do
      put("/app/cf-console/stop").should route_to("apps#stop", :name => "cf-console")
    end

    it "routes to #restart" do
      put("/app/cf-console/restart").should route_to("apps#restart", :name => "cf-console")
    end

    it "routes to #set_instances" do
      put("/app/cf-console/set_instances").should route_to("apps#set_instances", :name => "cf-console")
    end

    it "routes to #set_memsize" do
      put("/app/cf-console/set_memsize").should route_to("apps#set_memsize", :name => "cf-console")
    end

    it "routes to #set_var" do
      put("/app/cf-console/set_var").should route_to("apps#set_var", :name => "cf-console")
    end

    it "routes to #unset_var" do
      put("/app/cf-console/unset_var").should route_to("apps#unset_var", :name => "cf-console")
    end

    it "routes to #bind_service" do
      put("/app/cf-console/bind_service").should route_to("apps#bind_service", :name => "cf-console")
    end

    it "routes to #unbind_service" do
      put("/app/cf-console/unbind_service").should route_to("apps#unbind_service", :name => "cf-console")
    end

    it "routes to #map_url" do
      put("/app/cf-console/map_url").should route_to("apps#map_url", :name => "cf-console")
    end

    it "routes to #unmap_url" do
      put("/app/cf-console/unmap_url").should route_to("apps#unmap_url", :name => "cf-console")
    end

    it "routes to #files" do
      get("/app/cf-console/files/0/logs").should route_to("apps#files", :name => "cf-console", :instance => "0", :filename => "logs")
    end

    it "routes to #view_file" do
      get("/app/cf-console/view_file/0/stdout").should route_to("apps#view_file", :name => "cf-console", :instance => "0", :filename => "stdout")
    end
  end
end