require 'utils'

class AppsController < ApplicationController
  def index
    begin
      app = App.new(@cf_client)
      @apps = Utils::FiberedIterator.map(app.find_all_apps(), configatron.reactor_iterator.concurrency) do |app_info|
        app.find(app_info[:name])
      end
      @available_instances = find_available_instances('STOPPED', 1, 0)
      available_memsizes = find_available_memsizes('STOPPED', 0, 1)
      @available_memsizes = []
      available_memsizes.each do |key, value|
        @available_memsizes << [value, key]
      end
      @available_frameworks = find_available_frameworks_runtimes()
      @available_services = find_available_services()
      if configatron.suggest.app.url == true
        host = @cf_target_url.split("//")[1]
        @newapp_default_urldomain = host.split(".").drop(1).join(".")
      end
      @instances = 1
    rescue Exception => ex
      flash[:alert] = ex.message
    end
  end

  def create
    @name = params[:name]
    @instances = params[:instances]
    @memsize = params[:memsize]
    @type = params[:type]
    @url = params[:url]
    @service = params[:service]
    @deployform = params[:deployform]
    @gitrepo = params[:gitrepo]
    @gitbranch = params[:gitbranch]
    app_created = false
    if !@name.nil? && !@name.empty?
      if !@instances.nil? && !@instances.empty?
        if !@memsize.nil? && !@memsize.empty?
          if !@type.nil? && !@type.empty?
            if !@url.nil? && !@url.empty?
              begin
                framework, runtime = @type.split("/")
                app = App.new(@cf_client)
                app.create(@name.strip, @instances, @memsize, @url.strip.gsub(/^http(s*):\/\//i, '').downcase, framework, runtime, @service)
                @new_app = [] << app.find(@name.strip)
                flash[:notice] = "Application created. You must upload applications bits."
                app_created = true
              rescue Exception => ex
                flash[:alert] = ex.message
              end
            else
              flash[:alert] = "URL cannot be blank"
            end
          else
            flash[:alert] = "Type of application cannot be blank"
          end
        else
          flash[:alert] = "Memory size cannot be blank"
        end
      else
        flash[:alert] = "Number of instances cannot be blank"
      end
    else
      flash[:alert] = "Application name cannot be blank"
    end
    if app_created == true
      if !@gitrepo.nil? && !@gitrepo.strip.empty?
        if Utils::GitUtil.git_uri_valid?(@gitrepo.strip)
          begin
            @gitbranch = "master" if @gitbranch.nil? || @gitbranch.strip.empty?
            app = App.new(@cf_client)
            app.upload_app_from_git(@name, @gitrepo, @gitbranch)
            flash[:notice] = "Application created and bits uploaded."
          rescue Exception => ex
            flash[:notice] = "Application created but no bits were uploaded: " + ex.message
          end
        else
          flash[:notice] = "Application created but no bits were uploaded: Invalid Git Repository URI."
        end
      end
    end
    respond_to do |format|
      format.html { redirect_to apps_info_url }
      format.js { flash.discard }
    end
  end

  def show
    @name = params[:name]
    begin
      app = App.new(@cf_client)
      @app = app.find(@name)
      @app[:instances_info] = Utils::FiberedIterator.map(@app[:instances_info], configatron.reactor_iterator.concurrency) do |instance|
        if !instance[:stats].nil?
          instance[:logfiles] = find_log_files(@name, instance[:instance])
        else
          instance[:logfiles] = []
        end
        instance
      end
      @app[:services] = Utils::FiberedIterator.map(@app[:services], configatron.reactor_iterator.concurrency) do |service|
        find_service_details(service)
      end
      @app_files = find_files(@name, "/")
      @available_instances = find_available_instances(@app[:state], @app[:resources][:memory], @app[:instances])
      @available_memsizes = find_available_memsizes(@app[:state], @app[:resources][:memory], @app[:instances])
      @available_services = find_available_services()
    rescue CloudFoundry::Client::Exception::NotFound => ex
      flash[:alert] = ex.message
      redirect_to apps_info_url
    rescue Exception => ex
      flash[:alert] = ex.message
    end
  end

  def start
    @name = params[:name]
    begin
      app = App.new(@cf_client)
      @updated_app = [] << app.start(@name)
      @updated_app.collect! { |app_info| app.find(@name)}
      flash[:notice] = "Application \"" + @name + "\" started"
    rescue Exception => ex
      flash[:alert] = ex.message
    end
    respond_to do |format|
      format.html { redirect_to apps_info_url }
      format.js { flash.discard }
    end
  end

  def stop
    @name = params[:name]
    begin
      app = App.new(@cf_client)
      @updated_app = [] << app.stop(@name)
      @updated_app.collect! { |app_info| app.find(@name)}
      flash[:notice] = "Application \"" + @name + "\" stopped"
    rescue Exception => ex
      flash[:alert] = ex.message
    end
    respond_to do |format|
      format.html { redirect_to apps_info_url }
      format.js { flash.discard }
    end
  end

  def restart
    @name = params[:name]
    begin
      app = App.new(@cf_client)
      @updated_app = [] << app.restart(@name)
      @updated_app.collect! { |app_info| app.find(@name)}
      flash[:notice] = "Application \"" + @name + "\" restarted"
    rescue Exception => ex
      flash[:alert] = ex.message
    end
    respond_to do |format|
      format.html { redirect_to apps_info_url }
      format.js { flash.discard }
    end
  end

  def delete
    @name = params[:name]
    begin
      app = App.new(@cf_client)
      app.delete(@name)
      flash[:notice] = "Application \"" + @name + "\" deleted"
    rescue Exception => ex
      flash[:alert] = ex.message
    end
    respond_to do |format|
      format.html { redirect_to apps_info_url }
      format.js { flash.discard }
    end
  end

  def set_instances
    @name = params[:name]
    @instances = params[:instances]
    if !@instances.nil? && !@instances.empty?
      begin
        app = App.new(@cf_client)
        app.set_instances(@name, @instances)
        flash[:notice] = "Number of instances set to " + @instances
      rescue Exception => ex
        flash[:alert] = ex.message
      end
    else
      flash[:alert] = "Number of instances cannot be blank"
    end
    respond_to do |format|
      format.html { redirect_to app_info_url(@name) }
      format.js {
        if flash[:alert]
          render "apps/resources/set_instances", :status => :bad_request
        else
          render "apps/resources/set_instances"
        end
        flash.discard
      }
    end
  end

  def set_memsize
    @name = params[:name]
    @memsize = params[:memsize]
    if !@memsize.nil? && !@memsize.empty?
      begin
        app = App.new(@cf_client)
        app.set_memsize(@name, @memsize)
        flash[:notice] = "Memory set to " + @memsize
      rescue Exception => ex
        flash[:alert] = ex.message
      end
    else
      flash[:alert] = "Memory size cannot be blank"
    end
    respond_to do |format|
      format.html { redirect_to app_info_url(@name) }
      format.js {
        if flash[:alert]
          render "apps/resources/set_memsize", :status => :bad_request
        else
          render "apps/resources/set_memsize"
        end
        flash.discard
      }
    end
  end

  def set_var
    @name    = params[:name]
    @edit    = params[:edit]
    @restart = params[:restart]
    if @edit.nil?
      @var_name = params[:var_name].strip.upcase
    else
      envvar, @var_name = params[:id].split("-envvar-")
    end
    @var_value = params[:var_value]
    if !@var_name.nil? && !@var_name.empty?
      begin
        app = App.new(@cf_client)
        @var_exists = app.set_var(@name, @var_name, @var_value, @restart)
        @new_var = [] << {:var_name => @var_name, :var_value => @var_value}
        flash[:notice] = "Environment variable \"" + @var_name + "\" set"
      rescue Exception => ex
        flash[:alert] = ex.message
      end
    else
      flash[:alert] = "Variable name cannot be blank"
    end
    respond_to do |format|
      format.html { redirect_to app_info_url(@name) }
      format.js {
        if flash[:alert] && !@edit.nil?
          render "apps/envvars/set_var", :status => :bad_request
        else
          render "apps/envvars/set_var"
        end
        flash.discard
      }
    end
  end

  def unset_var
    @name = params[:name]
    @var_name = params[:var_name]
    begin
      app = App.new(@cf_client)
      app.unset_var(@name, @var_name)
      flash[:notice] = "Environment variable \"" + @var_name + "\" unset"
    rescue Exception => ex
      flash[:alert] = ex.message
    end
    respond_to do |format|
      format.html { redirect_to app_info_url(@name) }
      format.js {
        render "apps/envvars/unset_var"
        flash.discard
      }
    end
  end

  def bind_service
    @name = params[:name]
    @service = params[:service]
    if !@service.nil? && !@service.empty?
      begin
        app = App.new(@cf_client)
        app.bind_service(@name, @service)
        @new_service = [] << find_service_details(@service)
        flash[:notice] = "Service \"" + @service + "\" binded"
      rescue Exception => ex
        flash[:alert] = ex.message
      end
    else
      flash[:alert] = "Service cannot be blank"
    end
    respond_to do |format|
      format.html { redirect_to app_info_url(@name) }
      format.js {
        render "apps/services/bind_service"
        flash.discard
      }
    end
  end

  def unbind_service
    @name = params[:name]
    @service = params[:service]
    begin
      app = App.new(@cf_client)
      app.unbind_service(@name, @service)
      flash[:notice] = "Service \"" + @service + "\" unbinded"
    rescue Exception => ex
      flash[:alert] = ex.message
    end
    respond_to do |format|
      format.html { redirect_to app_info_url(@name) }
      format.js {
        render "apps/services/unbind_service"
        flash.discard
      }
    end
  end

  def map_url
    @name = params[:name]
    @url = params[:url].strip.gsub(/^http(s*):\/\//i, '').downcase
    if !@url.nil? && !@url.empty?
      begin
        app = App.new(@cf_client)
        @new_url = [] << app.map_url(@name, @url)
        flash[:notice] = "URL \"" + @url + "\" mapped"
      rescue Exception => ex
        flash[:alert] = ex.message
      end
    else
      flash[:alert] = "URL cannot be blank"
    end
    respond_to do |format|
      format.html { redirect_to app_info_url(@name) }
      format.js {
        render "apps/urls/map_url"
        flash.discard
      }
    end
  end

  def unmap_url
    @name = params[:name]
    @url = params[:url].gsub(/^http(s*):\/\//i, '')
    begin
      app = App.new(@cf_client)
      app.unmap_url(@name, @url)
      @url_hash = @url.hash.to_s
      flash[:notice] = "URL \"" + @url + "\" unmapped"
    rescue Exception => ex
      flash[:alert] = ex.message
    end
    respond_to do |format|
      format.html { redirect_to app_info_url(@name) }
      format.js {
        render "apps/urls/unmap_url"
        flash.discard
      }
    end
  end

  def update_bits
    @name = params[:name]
    @deployform = params[:deployform]
    @gitrepo = params[:gitrepo]
    @gitbranch = params[:gitbranch]
    if !@name.nil? && !@name.strip.empty?
      if !@gitrepo.nil? && !@gitrepo.strip.empty?
        if Utils::GitUtil.git_uri_valid?(@gitrepo.strip)
          begin
            @gitbranch = "master" if @gitbranch.nil? || @gitbranch.strip.empty?
            app = App.new(@cf_client)
            app.upload_app_from_git(@name, @gitrepo, @gitbranch)
            flash[:notice] = "Application bits uploaded."
          rescue Exception => ex
            flash[:alert] = ex.message
          end
        else
          flash[:alert] = "Invalid Git Repository URI"
        end
      else
        flash[:alert] = "Git Repository cannot be blank"
      end
    else
      flash[:alert] = "Application name cannot be blank"
    end
    respond_to do |format|
      format.html { redirect_to apps_info_url }
      format.js { flash.discard }
    end
  end

  def files
    @name = params[:name]
    @instance = params[:instance] || 0
    @filename = params[:filename]
    if !@filename.nil? && !@filename.empty?
      @filename = Base64.decode64(@filename)
      begin
        @app_files = find_files(@name, @filename, @instance)
      rescue Exception => ex
        flash[:alert] = ex.message
      end
    else
      flash[:alert] = "Filename cannot be blank"
    end
    respond_to do |format|
      format.html { redirect_to app_info_url(@name) }
      format.js {
        render "apps/files/files"
        flash.discard
      }
    end
  end

  def view_file
    @name = params[:name]
    @instance = params[:instance] || 0
    @filename = params[:filename]
    @formatcode = params[:formatcode] || "true"
    if !@filename.nil? && !@filename.empty?
      @filename = Base64.decode64(@filename)
      begin
        app = App.new(@cf_client)
        contents = app.view_file(@name, @filename, @instance)
        if !is_binary?(contents)
          if @formatcode == "true"
            lang = CodeRay::FileType[@filename]
            code = CodeRay.scan(contents, lang)
            @file_contents = code.html(:line_numbers => :table)
            @file_loc = code.loc
          else
            @file_contents = contents.split("\n")
          end
        else
          flash[:alert] = "Unable to display binary files"
        end
      rescue Exception => ex
        flash[:alert] = "File not found"
      end
    else
      flash[:alert] = "Filename cannot be blank"
    end
    respond_to do |format|
      format.html {
        render "apps/files/app_view_file", :layout => false
      }
      format.js {
        render "apps/files/view_file"
        flash.discard
      }
    end
  end

  private

  def find_available_frameworks_runtimes()
    available_frameworks = []
    system = System.new(@cf_client)
    frameworks = system.find_all_frameworks()
    if frameworks.empty?
      available_frameworks << ["No available frameworks", ""]
    else
      available_frameworks << ["Select a framework ...", ""]
      frameworks.each do |fwk_name, fwk|
        fwk[:runtimes].each do |run|
          available_frameworks << [fwk[:name].capitalize + " on " + run[:description], fwk_name.to_s + "/" + run[:name].to_s]
        end
      end
    end
    return available_frameworks
  end

  def find_available_instances(app_state, app_memsize, app_instances)
    system = System.new(@cf_client)
    available_for_use = system.find_available_memory()
    if app_state != 'STOPPED'
      available_for_use = available_for_use + (app_memsize.to_i * app_instances.to_i)
    end
    available_instances = available_for_use.to_i / app_memsize.to_i
    return available_instances
  end

  def find_available_memsizes(app_state, app_memsize, app_instances)
    system = System.new(@cf_client)
    available_for_use = system.find_available_memory()
    if app_state != 'STOPPED'
      available_for_use = available_for_use + (app_memsize.to_i * app_instances.to_i)
    end

    available_memsizes = {}
    available_memsizes[64] = "64 Mb" if available_for_use >= (64 * app_instances.to_i)
    available_memsizes[128] = "128 Mb" if available_for_use >= (128 * app_instances.to_i)
    available_memsizes[256] = "256 Mb" if available_for_use >= (256 * app_instances.to_i)
    available_memsizes[512] = "512 Mb" if available_for_use >= (512 * app_instances.to_i)
    available_memsizes[1024] = "1 Gb" if available_for_use >= (1024 * app_instances.to_i)
    available_memsizes[2048] = "2 Gb" if available_for_use >= (2048 * app_instances.to_i)
    if available_memsizes.empty?
      available_memsizes[""] = "Not enough memory available"
    else
      if app_memsize > 0
        available_memsizes["selected"] = app_memsize
      end
    end
    return available_memsizes
  end

  def find_available_services
    available_services = []
    service = Service.new(@cf_client)
    provisioned_services = service.find_all_services()
    if provisioned_services.empty?
      available_services << ["No available services", ""]
    else
      available_services << ["Select a service to bind ...", ""]
      provisioned_services.each do |service_info|
        available_services << [service_info[:name] + " (" + service_info[:vendor] + " " + service_info[:version] + ")", service_info[:name]]
      end
    end
    return available_services
  end

  def find_files(name, path, instance = 0)
    files = []
    begin
      app = App.new(@cf_client)
      contents = app.view_file(name, path, instance)
    rescue Exception => ex
      contents = ""
    end
    lines = contents.split("\n")
    lines.each do |line|
      filename = line.match('^[^ ]*')
      filesize = line.match('[^ ]*$')
      if filename.to_s.match('/$').nil?
        filetype = "file"
      else
        filetype = "dir"
      end
      files << {:name => filename.to_s, :size => filesize.to_s, :type => filetype, :path => path}
    end
    return files
  end

  def find_log_files(name, instance)
    instance_logs = []
    logfiles = find_files(name, "/logs", instance.to_i)
    if !logfiles.empty?
      ['stdout.log', 'stderr.log', 'startup.log', 'err.log', 'staging.log'].each do |log|
        logfiles.each do |logfile|
          if logfile[:name] == log && logfile[:size] != "0B"
            name = logfile[:name].split(".")
            instance_logs << {:name => name[0], :path => "logs/" + logfile[:name]}
            break
          end
        end
      end
    end
    return instance_logs
  end

  def find_service_details(name)
    service = Service.new(@cf_client)
    service_details = service.find(name)
    if service_details.empty?
      return {:name => name, :vendor => "", :version => "" }
    else
      return {:name => name, :vendor => service_details[:vendor], :version => service_details[:version] }
    end
  end

  def is_binary?(string)
    string.each_byte do |x|
      x.nonzero? or return true
    end
    false
  end
end
