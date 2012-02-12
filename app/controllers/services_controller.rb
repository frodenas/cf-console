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
          begin
            service_info = service.find(@name)
          rescue
            service_info = nil
          end
          if service_info.nil?
            service.create(@name, @ss)
            service_info = service.find(@name)
            if !service_info.nil?
              @new_service = [] << service_info
              flash[:notice] = t('services.controller.service_created', :name => @name)
            else
              flash[:alert] = t('services.controller.request_error')
            end
          else
            flash[:alert] = t('services.controller.already_exists')
          end
        rescue Exception => ex
          flash[:alert] = ex.message
        end
      else
        flash[:alert] = t('services.controller.service_blank')
      end
    else
      flash[:alert] = t('services.controller.name_blank')
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
      flash[:notice] = t('services.controller.service_deleted', :name => @name)
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
    available_system_services << [t('services.controller.select_service'), ""]
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