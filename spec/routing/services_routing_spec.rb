require 'spec_helper'

describe ServicesController do
  describe 'routes to' do
    it 'services#index' do
      get("/services").should route_to("services#index")
    end

    it 'services#create' do
      post("/services").should route_to("services#create")
    end

    it 'services#delete' do
      delete("/services/mysql").should route_to("services#delete", :name => "mysql")
    end
  end
end