class ServicesController < ApplicationController
  def index
    begin
      service = Service.new(@cf_client)
      @services = service.find_all_services()
      binded_apps = find_binded_apps()
      @services.collect {|service_item| service_item[:bindedapps] = binded_apps[service_item[:name]] ||= [] }
      @available_system_services = find_available_system_services()
    rescue Exception => ex
      flash[:alert] = ex.message
    end
  end

  def create
    @name = params[:name].strip.downcase
    @ss = params[:ss]
    if !@name.nil? && !@name.empty?
      if !@ss.nil? && !@ss.empty?
        begin
          service = Service.new(@cf_client)
          service_info = service.find(@name)
          if service_info.nil?
            service.create(@name, @ss)
            service_info = service.find(@name)
            if !service_info.nil?
              @new_service = [] << service_info
              flash[:notice] = "Service \"" + @name + "\" provisioned"
            else
              flash[:alert] = "An error occurred processing your request, please reload the page and try again."
            end
          else
            flash[:alert] = "Service name already exists"
          end
        rescue Exception => ex
          flash[:alert] = ex.message
        end
      else
        flash[:alert] = "You must select a service"
      end
    else
      flash[:alert] = "Service name cannot be blank"
    end
    respond_to do |format|
      format.html { redirect_to services_info_url }
      format.js { flash.discard }
    end
  end

  def delete
    @name = params[:name]
    begin
      service = Service.new(@cf_client)
      service.delete(@name)
      flash[:notice] = "Service \"" + @name + "\" deprovisioned"
    rescue Exception => ex
      flash[:alert] = ex.message
    end
    respond_to do |format|
      format.html { redirect_to services_info_url }
      format.js { flash.discard }
    end
  end

  def find_binded_apps()
    bindedapps = {}
    app = App.new(@cf_client)
    apps = app.find_all_apps()
    apps.each do |app_item|
      next unless app_item[:services]
      app_item[:services].each do |service_item|
        bindedapps[service_item] ||= []
        bindedapps[service_item] << app_item[:name]
      end
    end
    return bindedapps
  end

  def find_available_system_services
    available_system_services = []
    available_system_services << ["Select a system service ...", ""]
    system = System.new(@cf_client)
    system_services = system.find_all_system_services()
    system_services.each do |service_type, service_value|
      service_value.each do |vendor, vendor_value|
        vendor_value.each do |version, service_info|
          available_system_services << [service_info[:vendor] + " " + service_info[:version], service_info[:vendor]]
        end
      end
    end
    return available_system_services
  end
end