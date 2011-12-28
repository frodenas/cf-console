module ApplicationHelper
  def colorize_state(state)
    status = case state
      when "RUNNING"  then '<span class="state-green">' + state + '</span>'
      when "STARTED"  then '<span class="state-green">' + state + '</span>'
      when "STARTING" then '<span class="state-green">' + state + '</span>'
      when "FLAPPING" then '<span class="state-orange">' + state + '</span>'
      else '<span class="state-red">' + state + '</span>'
     end
    return status
  end

  def find_vendor_image(vendor)
    asset_found = false
    Rails.application.config.assets.paths.each do |path|
      if FileTest.exist?(File.join(path, vendor.strip + ".png"))
        asset_found = true
        break
      end
    end
    if asset_found == true
      return image_tag(vendor + ".png", :alt => vendor)
    else
      return(vendor)
    end
  end

  def git_deploy_available?
    return false if configatron.deploy_from.git_available != true
    return false if Utils::GitUtil.git_binary().nil?
    true
  end

  def health(app)
    return '<span class="state-red">N/A</span>' unless (app and app[:state])
    return '<span class="state-red">STOPPED</span>' if app[:state] == 'STOPPED'

    health = nil
    healthy_instances = app[:runningInstances]
    expected_instances = app[:instances]
    if app[:state] == "STARTED" && expected_instances > 0 && healthy_instances
      health = format("%.3f", healthy_instances.to_f / expected_instances).to_f
    end

    if health
      if health == 0
        return '<span class="state-red">0%</span>'
      elsif health == 1
        return '<span class="state-green">RUNNING</span>'
      else
        return '<span class="state-orange">Running at ' + ((health * 100).round).to_s   + '%</span>'
      end
    end
    return '<span class="state-red">N/A</span>'
  end

  def pct(usage, limit)
    pct = (usage / limit) * 100.00
  end

  def pretty_size(size, prec = 1)
    return "NA" unless size
    return "#{size} b" if size < 1024
    return sprintf("%.#{prec}f Kb", size / 1024.0) if size < (1024 * 1024)
    return sprintf("%.#{prec}f Mb", size / (1024.0 * 1024.0)) if size < (1024 * 1024 * 1024)
    return sprintf("%.#{prec}f Gb", size / (1024.0 * 1024.0 * 1024.0))
  end

  def title(page_title)
    content_for(:title) { page_title }
    return
  end

  def uptime_string(delta)
    num_seconds = delta.to_i
    days = num_seconds / (60 * 60 * 24)
    num_seconds -= days * (60 * 60 * 24)
    hours = num_seconds / (60 * 60)
    num_seconds -= hours * (60 * 60)
    minutes = num_seconds / 60
    num_seconds -= minutes * 60
    "#{days}d:#{hours}h:#{minutes}m:#{num_seconds}s"
  end
end
