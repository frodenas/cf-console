require 'spec_helper'

describe SystemController do
  describe 'routes to' do
    it 'system#index' do
      get("/system").should route_to("system#index")
    end
  end
end