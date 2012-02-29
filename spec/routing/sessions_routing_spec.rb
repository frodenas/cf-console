require 'spec_helper'

describe SessionsController do
  describe 'routes to' do
    it 'sessions#new' do
      get("/login").should route_to("sessions#new")
    end

    it 'sessions#create' do
      post("/login").should route_to("sessions#create")
    end

    it 'sessions#destroy' do
      get("/logout").should route_to("sessions#destroy")
    end
  end
end