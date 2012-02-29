require 'spec_helper'

describe UsersController do
  describe 'routes to' do
    it 'users#index' do
      get("/users").should route_to("users#index")
    end

    it 'users#create' do
      post("/users").should route_to("users#create")
    end

    it 'users#delete' do
      delete("/users/frodenas").should route_to("users#delete", :name => "frodenas")
    end
  end
end