class App

  SLEEP_TIME  = 1
  GIVEUP_TICKS  = 120 / SLEEP_TIME
  HEALTH_TICKS  = 5 / SLEEP_TIME

  def initialize(cf_client)
    @cf_client = cf_client
  end

  def find_all_apps()
    return @cf_client.list_apps || []
  end

  def find_all_states()
    app_states = []
    states = {}
    apps = find_all_apps()
    apps.each do |app_info|
      if states[app_info[:state]]
        states[app_info[:state]] += 1
      else
        states[app_info[:state]] = 1
      end
    end
    states.each do |state_key, state_value|
      if state_value > 0
        app_states << {:label => state_key.capitalize, :color => state_color(state_key), :data => state_value}
      end
    end
    return app_states
  end

  def find(name)
    raise "Application name cannot be blank" if name.nil? || name.empty?
    app_info = @cf_client.app_info(name) || {}
    if !app_info.empty?
      app_info[:instances_info] = find_app_instances(name)
      app_info[:crashes] = find_app_crashes(name)
      app_info[:instances_states] = find_app_instances_states(app_info)
      app_info[:env].collect! { |env|
        var, value = env.split("=")
        {:var_name => var, :var_value => value}
      }
    end
    return app_info
  end

  def find_app_instances(name)
    raise "Application name cannot be blank" if name.nil? || name.empty?
    app_instances = []
    instances_info = @cf_client.app_instances(name) || {}
    if !instances_info.empty? && !instances_info[:instances].empty?
      instances_stats = @cf_client.app_stats(name) || []
    else
      instances_stats = []
    end
    instances_info.each do |instances, instances_value|
      instances_value.each do |info|
        stats = nil
        instances_stats.each do |stats_value|
          if stats_value[:instance] == info[:index]
            stats = stats_value[:stats]
            break
          end
        end
        app_instances << {:instance => info[:index], :state => info[:state], :stats => stats}
      end
    end
    return app_instances
  end

  def find_app_crashes(name)
    raise "Application name cannot be blank" if name.nil? || name.empty?
    return @cf_client.app_crashes(name)[:crashes] || {}
  end

  def find_app_instances_states(app_info)
    app_instances_states = []
    return app_instances_states unless app_info

    states = {}
    if !app_info[:instances_info].empty?
      app_info[:instances_info].each do |instance_info|
        if states[instance_info[:state]]
          states[instance_info[:state]] += 1
        else
          states[instance_info[:state]] = 1
        end
      end
    else
      states["STOPPED"] = app_info[:instances]
    end
    states["CRASHED"] = app_info[:crashes].length
    states.each do |state_key, state_value|
      if state_value > 0
        app_instances_states << {:label => state_key.capitalize, :color => state_color(state_key), :data => state_value}
      end
    end
    return app_instances_states
  end

  def create(name, instances, memsize, url, framework, runtime, service)
    raise "Application name cannot be blank" if name.nil? || name.empty?
    raise "Invalid application name: \"" + name + "\". Must contain only word characters (letter, number, hyphen, underscore)" if (name =~ /^[\w-]+$/).nil?
    begin
      app_info = @cf_client.app_info(name)
    rescue
      app_info = nil
    end
    raise "Application name already exists" if !app_info.nil?
    raise "Number of instances cannot be blank" if instances.nil? || instances.empty?
    raise "Number of instances must be numeric" if (instances =~ /^\d+$/).nil?
    raise "There must be at least 1 instance" if instances.to_i < 1
    raise "Memory size cannot be blank" if memsize.nil? || memsize.empty?
    raise "Memory size must be numeric" if (memsize =~ /^\d+$/).nil?
    raise "Not enough memory available" if !check_has_capacity_for(instances.to_i * memsize.to_i)
    raise "URL cannot be blank" if url.nil? || url.empty?
    raise "Framework cannot be blank" if framework.nil? || framework.empty?
    raise "Runtime cannot be blank" if runtime.nil? || runtime.empty?
    raise "Invalid Framework or Runtime" if !valid_framework_and_runtime?(framework, runtime)
    manifest = {
      :name => name,
      :instances => instances,
      :resources => {:memory => memsize},
      :uris => [url],
      :staging => {:framework => framework, :runtime => runtime},
    }
    manifest[:services] = [service] if !service.nil? && !service.empty?
    @cf_client.create_app(name, manifest)
  end

  def start(name)
    raise "Application name cannot be blank" if name.nil? || name.empty?
    app = @cf_client.app_info(name)
    app[:state] = "STARTED"
    @cf_client.update_app(name, app)
    count = 0
    start_time = Time.now.to_i
    loop do
      sleep SLEEP_TIME
      break if app_started_properly(name, count < HEALTH_TICKS)
      if !app_crashes(name, start_time).empty?
        raise "Application failed to start, check your logs"
        break
      end
      count += 1
      if count > GIVEUP_TICKS
        raise "Application is taking too long to start, check your logs"
        break
      end
    end
    return @cf_client.app_info(name) || {}
  end

  def stop(name)
    raise "Application name cannot be blank" if name.nil? || name.empty?
    app = @cf_client.app_info(name)
    app[:state] = "STOPPED"
    @cf_client.update_app(name, app)
    return app
  end

  def restart(name)
    raise "Application name cannot be blank" if name.nil? || name.empty?
    app = stop(name)
    app = start(name)
    return app
  end

  def delete(name)
    raise "Application name cannot be blank" if name.nil? || name.empty?
    @cf_client.delete_app(name)
  end

  def set_instances(name, instances)
    raise "Application name cannot be blank" if name.nil? || name.empty?
    raise "Number of instances cannot be blank" if instances.nil? || instances.empty?
    raise "Number of instances must be numeric" if (instances =~ /^\d+$/).nil?
    raise "There must be at least 1 instance" if instances.to_i < 1
    app = @cf_client.app_info(name)
    current_instances = app[:instances]
    wanted_mem = instances.to_i * app[:resources][:memory]
    if app[:state] != 'STOPPED'
      wanted_mem = wanted_mem - (current_instances * app[:resources][:memory])
    end
    if !check_has_capacity_for(wanted_mem)
      raise "Not enough memory available"
    end
    if (instances.to_i != current_instances.to_i)
      app[:instances] = instances
      @cf_client.update_app(name, app)
    end
    return true
  end

  def set_memsize(name, memsize)
    raise "Application name cannot be blank" if name.nil? || name.empty?
    raise "Memory size cannot be blank" if memsize.nil? || memsize.empty?
    raise "Memory size must be numeric" if (memsize =~ /^\d+$/).nil?
    app = @cf_client.app_info(name)
    current_memory = app[:resources][:memory]
    wanted_mem = memsize.to_i * app[:instances]
    if app[:state] != 'STOPPED'
      wanted_mem = wanted_mem - (current_memory * app[:instances])
    end
    if !check_has_capacity_for(wanted_mem)
      raise "Not enough memory available"
    end
    if (memsize.to_i != current_memory.to_i)
      app[:resources][:memory] = memsize
      @cf_client.update_app(name, app)
      check_app_for_restart(name)
    end
    return true
  end

  def set_var(name, var_name, var_value, restart = "true")
    raise "Application name cannot be blank" if name.nil? || name.empty?
    raise "Variable name cannot be blank" if var_name.nil? || var_name.empty?
    raise "Invalid variable name: \"" + var_name + "\". Must contain only word characters (letter, number, hyphen, underscore)" if (var_name =~ /^[\w-]+$/).nil?
    app = @cf_client.app_info(name)
    envvars = app[:env] || []
    var_exists = nil
    envvars.each do |env|
      var, value = env.split('=')
      if (var == var_name)
        var_exists = env
        break
      end
    end
    if var_exists
      envvars.delete(var_exists)
    end
    envvars << "#{var_name}=#{var_value}"
    app[:env] = envvars
    @cf_client.update_app(name, app)
    if restart == "true"
      check_app_for_restart(name)
    end
    return var_exists
  end

  def unset_var(name, var_name)
    raise "Application name cannot be blank" if name.nil? || name.empty?
    raise "Variable name cannot be blank" if var_name.nil? || var_name.empty?
    app = @cf_client.app_info(name)
    envvars = app[:env] || []
    var_deleted = nil
    envvars.each do |env|
      var, value = env.split('=')
      if (var == var_name)
        var_deleted = env
        break
      end
    end
    if var_deleted
      envvars.delete(var_deleted)
      app[:env] = envvars
      @cf_client.update_app(name, app)
      check_app_for_restart(name)
    else
      raise "Environment variable \"" + var_name + "\" is not set"
    end
    return var_deleted
  end

  def bind_service(name, service)
    raise "Application name cannot be blank" if name.nil? || name.empty?
    raise "Service cannot be blank" if service.nil? || service.empty?
    app = @cf_client.app_info(name)
    services = app[:services] || []
    service_exists = services.index(service)
    if !service_exists
      app[:services] = services << service
      @cf_client.update_app(name, app)
      check_app_for_restart(name)
    else
      raise "Service \"" + service + "\" already binded"
    end
    return true
  end

  def unbind_service(name, service)
    raise "Application name cannot be blank" if name.nil? || name.empty?
    raise "Service cannot be blank" if service.nil? || service.empty?
    app = @cf_client.app_info(name)
    services = app[:services] || []
    service_deleted = services.delete(service)
    if service_deleted
      app[:services] = services
      @cf_client.update_app(name, app)
      check_app_for_restart(name)
    else
      raise "Service \"" + service + "\" is not binded"
    end
    return true
  end

  def map_url(name, url)
    raise "Application name cannot be blank" if name.nil? || name.empty?
    raise "URL cannot be blank" if url.nil? || url.empty?
    url = url.strip.gsub(/^http(s*):\/\//i, '').downcase
    app = @cf_client.app_info(name)
    uris = app[:uris] || []
    url_exists = uris.index(url)
    if !url_exists
      app[:uris] = uris << url
      @cf_client.update_app(name, app)
    else
      raise "URL \"" + url + "\" already mapped"
    end
    return url
  end

  def unmap_url(name, url)
    raise "Application name cannot be blank" if name.nil? || name.empty?
    raise "URL cannot be blank" if url.nil? || url.empty?
    url = url.strip.gsub(/^http(s*):\/\//i, '').downcase
    app = @cf_client.app_info(name)
    uris = app[:uris] || []
    url_deleted = uris.delete(url)
    if url_deleted
      app[:uris] = uris
      @cf_client.update_app(name, app)
    else
      raise "URL \"" + url + "\" is not mapped"
    end
    return url
  end

  def upload_app(name, zipfile, resource_manifest = [])
    raise "Application name cannot be blank" if name.nil? || name.empty?
    raise "Zipfile cannot be blank" if zipfile.nil? || zipfile.empty?
    @cf_client.upload_app(name, zipfile, resource_manifest)
  end

  def upload_app_from_git(name, gitrepo, gitbranch)
    raise "Application name cannot be blank" if name.nil? || name.empty?
    raise "Invalid application name: \"" + name + "\". Must contain only word characters (letter, number, hyphen, underscore)" if (name =~ /^[\w-]+$/).nil?
    raise "Git Repository URI cannot be blank" if gitrepo.nil? || gitrepo.empty?
    raise "Git Repository Branch cannot be blank" if gitbranch.nil? || gitbranch.empty?
    app_bits_tmpdir = get_app_bits_tmpdir()
    repodir = app_bits_tmpdir.join(name).to_s
    Utils::GitUtil.git_clone(gitrepo, gitbranch, repodir)
    zipfile = app_bits_tmpdir.join(name + ".zip").to_s
    files = get_files_to_pack(repodir)
    Utils::ZipUtil.pack_files(zipfile, files)
    files.each { |f| f[:fn] = f[:zn]}
    upload_app(name, zipfile, files)
  ensure
    FileUtils.rm_f(zipfile) if zipfile
    FileUtils.rm_rf(repodir, :secure => true) if repodir
  end

  def download_app(name)
    raise "Application name cannot be blank" if name.nil? || name.empty?
    app_bits_tmpdir = get_app_bits_tmpdir()
    zipfile = app_bits_tmpdir.join(name + ".zip").to_s
    app_bits = @cf_client.download_app(name)
    File.open(zipfile, "w") {|f| f.write(app_bits.force_encoding("utf-8").encode) }
    zipfile
  end

  def view_file(name, path, instance = 0)
    raise "Application name cannot be blank" if name.nil? || name.empty?
    raise "Path cannot be blank" if path.nil? || path.empty?
    contents = @cf_client.app_files(name, path, instance) || []
    return contents
  end

  private

  def app_crashes(name, since = 0)
    crashes = @cf_client.app_crashes(name)[:crashes] || {}
    crashes.delete_if {|crash| crash[:since] < since}
    return crashes
  end

  def app_started_properly(name, error_on_health)
    app = @cf_client.app_info(name)
    case health(app)
      when 'N/A'
        raise "Application state is undetermined, not enough information available" if error_on_health
        return false
      when 'RUNNING'
        return true
      else
        return false
    end
  end

  def check_app_for_restart(name)
    app = @cf_client.app_info(name) || {}
    restart(name) if app[:state] == 'STARTED'
  end

  def check_has_capacity_for(wanted_mem)
    system = System.new(@cf_client)
    available_for_use = system.find_available_memory()
    return (available_for_use - wanted_mem.to_i) >= 0
  end

  def check_resources(resources = [])
    @cf_client.check_resources(resources)
  end

  def get_app_bits_tmpdir()
    Rails.root.join('tmp').join('app-bits')
  end

  def get_files_to_pack(repodir)
    files = []
    total_size = 0
    Dir.glob("#{repodir}/**/*", File::FNM_DOTMATCH).select do |f|
      process = true
      ['*/.git', '*/.git/*'].each { |e| process = false if File.fnmatch(e, f) }
      ['..', '.', '*~', '#*#', '*.log'].each { |e| process = false if File.fnmatch(e, File.basename(f)) }
      if process == true
        if (!File.directory?(f) && File.exists?(f))
          files << {:fn => f, :zn => f.sub("#{repodir}/", ""), :size => File.size(f), :sha1 => Digest::SHA1.file(f).hexdigest}
          total_size += File.size(f)
        end
      end
    end
    if (total_size > (64*1024))
      files = check_resources(files)
    end
    if files.empty?
      f = repodir + "/.__empty__"
      File.new(f, "w")
      files << {:fn => f, :zn => f.sub("#{repodir}/", ""), :size => File.size(f), :sha1 => Digest::SHA1.file(f).hexdigest}
    end
    files
  end

  def health(app)
    return 'N/A' unless (app and app[:state])
    return 'STOPPED' if app[:state] == 'STOPPED'

    health = nil
    healthy_instances = app[:runningInstances]
    expected_instances = app[:instances]
    if app[:state] == "STARTED" && expected_instances > 0 && healthy_instances
      health = format("%.3f", healthy_instances.to_f / expected_instances).to_f
    end

    return 'RUNNING' if health && health == 1.0
    return "#{(health * 100).round}%" if health
    return 'N/A'
  end

  def state_color(state)
    color = case state
      when "RUNNING"        then "#7FDB49"
      when "STARTED"        then "#7FDB49"
      when "STARTING"       then "#5BDED3"
      when "STOPPED"        then "#C70E17"
      when "FLAPPING"       then "#FF8C00"
      when "DOWN"           then "#941218"
      #when "CRASHED"        then "#F71823"
      #when "DEA_SHUTDOWN"   then "#F71823"
      #when "DEA_EVACUATION" then "#F71823"
      else "#F71823"
     end
    return color
  end

  def valid_framework_and_runtime?(framework, runtime)
    system = System.new(@cf_client)
    frameworks = system.find_all_frameworks()
    frameworks.each do |fwk_name, fwk|
      fwk[:runtimes].each do |run|
         return true if (fwk[:name] == framework && run[:name] == runtime)
      end
    end
    return false
  end
end