require 'spec_helper'

describe AppsController do
  describe 'routes to' do
    it 'apps#index' do
      get("/apps").should route_to("apps#index")
    end

    it 'apps#create' do
      post("/apps").should route_to("apps#create")
    end

    it 'apps#show' do
      get("/app/cf-console").should route_to("apps#show", :name => "cf-console")
    end

    it 'apps#delete' do
      delete("/app/cf-console").should route_to("apps#delete", :name => "cf-console")
    end

    it 'apps#start' do
      put("/app/cf-console/start").should route_to("apps#start", :name => "cf-console")
    end

    it 'apps#stop' do
      put("/app/cf-console/stop").should route_to("apps#stop", :name => "cf-console")
    end

    it 'apps#restart' do
      put("/app/cf-console/restart").should route_to("apps#restart", :name => "cf-console")
    end

    it 'apps#set_instances' do
      put("/app/cf-console/set_instances").should route_to("apps#set_instances", :name => "cf-console")
    end

    it 'apps#set_memsize' do
      put("/app/cf-console/set_memsize").should route_to("apps#set_memsize", :name => "cf-console")
    end

    it 'apps#set_var' do
      put("/app/cf-console/set_var").should route_to("apps#set_var", :name => "cf-console")
    end

    it 'apps#unset_var' do
      put("/app/cf-console/unset_var").should route_to("apps#unset_var", :name => "cf-console")
    end

    it 'apps#bind_service' do
      put("/app/cf-console/bind_service").should route_to("apps#bind_service", :name => "cf-console")
    end

    it 'apps#unbind_service' do
      put("/app/cf-console/unbind_service").should route_to("apps#unbind_service", :name => "cf-console")
    end

    it 'apps#map_url' do
      put("/app/cf-console/map_url").should route_to("apps#map_url", :name => "cf-console")
    end

    it 'apps#unmap_url' do
      put("/app/cf-console/unmap_url").should route_to("apps#unmap_url", :name => "cf-console")
    end

    it 'apps#update_bits' do
      put("/app/cf-console/update_bits").should route_to("apps#update_bits", :name => "cf-console")
    end

    it 'apps#download_bits' do
      get("/app/cf-console/download_bits").should route_to("apps#download_bits", :name => "cf-console")
    end

    it 'apps#files' do
      get("/app/cf-console/files/0/logs").should route_to("apps#files", :name => "cf-console", :instance => "0", :filename => "logs")
    end

    it 'apps#view_file' do
      get("/app/cf-console/view_file/0/stdout").should route_to("apps#view_file", :name => "cf-console", :instance => "0", :filename => "stdout")
    end
  end
end