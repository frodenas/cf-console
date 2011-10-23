class App

  SLEEP_TIME  = 1
  GIVEUP_TICKS  = 120 / SLEEP_TIME
  HEALTH_TICKS  = 5 / SLEEP_TIME

  def initialize(cf_conn)
    @cf_conn = cf_conn
  end

  def find_all_apps()
    return @cf_conn.apps || []
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
    app_info = @cf_conn.app_info(name) || {}
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
    app_instances = []
    instances_info = @cf_conn.app_instances(name) || {}
    if !instances_info.empty? && !instances_info[:instances].empty?
      instances_stats = @cf_conn.app_stats(name) || []
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
    return @cf_conn.app_crashes(name)[:crashes] || {}
  end

  def find_app_instances_states(app_info)
    app_instances_states = []
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

  def start(name)
    if name.nil? || name.empty?
      raise "Application name cannot be blank"
    end
    app = @cf_conn.app_info(name)
    app[:state] = "STARTED"
    @cf_conn.update_app(name, app)
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
    return @cf_conn.app_info(name) || {}
  end

  def stop(name)
    if name.nil? || name.empty?
      raise "Application name cannot be blank"
    end
    app = @cf_conn.app_info(name)
    app[:state] = "STOPPED"
    @cf_conn.update_app(name, app)
    return app
  end

  def restart(name)
    if name.nil? || name.empty?
      raise "Application name cannot be blank"
    end
    app = stop(name)
    app = start(name)
    return app
  end

  def delete(name)
    if name.nil? || name.empty?
      raise "Application name cannot be blank"
    end
    @cf_conn.delete_app(name)
  end

  def set_instances(name, instances)
    if name.nil? || name.empty?
      raise "Application name cannot be blank"
    end
    if instances.nil? || instances.empty?
      raise "Number of instances cannot be blank"
    end
    if (instances =~ /^\d+$/).nil?
      raise "Number of instances must be numeric"
    end
    if instances.to_i < 1
      raise "There must be at least 1 instance"
    end
    app = @cf_conn.app_info(name)
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
      @cf_conn.update_app(name, app)
    end
  end

  def set_memsize(name, memsize)
    if name.nil? || name.empty?
      raise "Application name cannot be blank"
    end
    if memsize.nil? || memsize.empty?
      raise "Memory size cannot be blank"
    end
    if (memsize =~ /^\d+$/).nil?
      raise "Memory size must be numeric"
    end
    app = @cf_conn.app_info(name)
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
      @cf_conn.update_app(name, app)
      check_app_for_restart(name)
    end
  end

  def set_var(name, var_name, var_value, restart = "true")
    if name.nil? || name.empty?
      raise "Application name cannot be blank"
    end
    if var_name.nil? || var_name.empty?
      raise "Variable name cannot be blank"
    end
    if (var_name =~ /^[\w-]+$/).nil?
      raise "Invalid variable name: \"" + var_name + "\". Must contain only word characters (letter, number, underscore)"
    end
    app = @cf_conn.app_info(name)
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
    @cf_conn.update_app(name, app)
    if restart == "true"
      check_app_for_restart(name)
    end
    return var_exists
  end

  def unset_var(name, var_name)
    if name.nil? || name.empty?
      raise "Application name cannot be blank"
    end
    if var_name.nil? || var_name.empty?
      raise "Variable name cannot be blank"
    end
    app = @cf_conn.app_info(name)
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
      @cf_conn.update_app(name, app)
      check_app_for_restart(name)
    else
      raise "Environment variable \"" + var_name + "\" is not set"
    end
  end

  def bind_service(name, service)
    if name.nil? || name.empty?
      raise "Application name cannot be blank"
    end
    if service.nil? || service.empty?
      raise "Service cannot be blank"
    end
    app = @cf_conn.app_info(name)
    services = app[:services] || []
    service_exists = services.index(service)
    if !service_exists
      app[:services] = services << service
      @cf_conn.update_app(name, app)
      check_app_for_restart(name)
    else
      raise "Service \"" + service + "\" already binded"
    end
  end

  def unbind_service(name, service)
    if name.nil? || name.empty?
      raise "Application name cannot be blank"
    end
    if service.nil? || service.empty?
      raise "Service cannot be blank"
    end
    app = @cf_conn.app_info(name)
    services = app[:services] || []
    service_deleted = services.delete(service)
    if service_deleted
      app[:services] = services
      @cf_conn.update_app(name, app)
      check_app_for_restart(name)
    else
      raise "Service \"" + service + "\" is not binded"
    end
  end

  def map_url(name, url)
    if name.nil? || name.empty?
      raise "Application name cannot be blank"
    end
    if url.nil? || url.empty?
      raise "URL cannot be blank"
    end
    app = @cf_conn.app_info(name)
    uris = app[:uris] || []
    url_exists = uris.index(url)
    if !url_exists
      app[:uris] = uris << url
      @cf_conn.update_app(name, app)
    else
      raise "URL \"" + url + "\" already mapped"
    end
    return url
  end

  def unmap_url(name, url)
    if name.nil? || name.empty?
      raise "Application name cannot be blank"
    end
    if url.nil? || url.empty?
      raise "URL cannot be blank"
    end
    app = @cf_conn.app_info(name)
    uris = app[:uris] || []
    url_deleted = uris.delete(url)
    if url_deleted
      app[:uris] = uris
      @cf_conn.update_app(name, app)
    else
      raise "URL \"" + url + "\" is not mapped"
    end
    return url
  end

  def view_file(name, path, instance)
    if name.nil? || name.empty?
      raise "Application name cannot be blank"
    end
    if instance.nil?
      raise "Instance cannot be blank"
    end
    contents = @cf_conn.app_files(name, path, instance) || []
    return contents
  end

  private

  def app_crashes(name, since = 0)
    crashes = @cf_conn.app_crashes(name)[:crashes] || {}
    crashes.delete_if {|crash| crash[:since] < since}
    return crashes
  end

  def app_started_properly(name, error_on_health)
    app = @cf_conn.app_info(name)
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
    app = @cf_conn.app_info(name) || {}
    restart(name) if app[:state] == 'STARTED'
  end

  def check_has_capacity_for(wanted_mem)
    system = System.new(@cf_conn)
    available_for_use = system.find_available_memory()
    return (available_for_use - wanted_mem.to_i) >= 0
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
end