require 'spec_helper'

describe DashboardController do
  describe 'routes to' do
    it 'dashboard#index' do
      get("/dashboard").should route_to("dashboard#index")
    end
  end
end