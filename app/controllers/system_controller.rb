class SystemController < ApplicationController
  def index
    begin
      system = System.new(@cf_client)
      @info = system.find_account_info()
      @frameworks = system.find_all_frameworks()
      @runtimes = system.find_all_runtimes()
      @system_services = system.find_all_system_services()
    rescue Exception => ex
      flash[:alert] = ex.message
    end
  end
end