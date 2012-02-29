module ApplicationHelper
  def colorize_state(state)
    status = case state
      when "RUNNING"  then '<span class="state-green">' + I18n.t('helpers.running') + '</span>'
      when "STARTED"  then '<span class="state-green">' + I18n.t('helpers.started') + '</span>'
      when "STARTING" then '<span class="state-green">' + I18n.t('helpers.starting') + '</span>'
      when "STOPPED" then '<span class="state-red">' + I18n.t('helpers.stopped') + '</span>'
      when "FLAPPING" then '<span class="state-orange">' + I18n.t('helpers.flapping') + '</span>'
      else '<span class="state-red">' + state + '</span>'
     end
  end

  def find_vendor_image(vendor)
    vendor_images = configatron.sprites.vendor_images || []
    if vendor_images.include?(vendor.strip)
      return image_tag("s.gif", {:class => vendor, :alt => vendor})
    else
      Rails.application.config.assets.paths.each do |path|
        if FileTest.exist?(File.join(path, "vendor_images", vendor.strip + ".png"))
          return image_tag("vendor_images/" + vendor.strip + ".png", :alt => vendor)
        end
      end
    end
    vendor
  end

  def git_deploy_available?
    return false if !configatron.deploy_from.git_available
    return false if Utils::GitUtil.git_binary().nil?
    true
  end

  def health(app)
    return '<span class="state-red">' + I18n.t('helpers.na') + '</span>' unless (app and app[:state])
    return '<span class="state-red">' + I18n.t('helpers.stopped') + '</span>' if app[:state] == 'STOPPED'

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
        return '<span class="state-green">' + I18n.t('helpers.running') + '</span>'
      else
        return '<span class="state-orange">' + I18n.t('helpers.running_at') + ' ' + ((health * 100).round).to_s   + '%</span>'
      end
    end
    '<span class="state-red">' + I18n.t('helpers.na') + '</span>'
  end

  def language_selector
    available_locales = (I18n.available_locales.collect { |lang| lang.to_s } & configatron.languages.available).sort
    return "" if available_locales.length <= 1
    selector = "<li id=\"locale\">"
    selector += "<a id=\"locale-trigger\" href=\"#\">"
    selector += image_tag("s.gif", {:class => "flag_" + I18n.locale.to_s, :alt => I18n.locale.to_s, :width => 20, :height => 12})
    selector += " " + I18n.t('meta.language_name') + " <span>&#x25BC;</span>"
    selector += "</a>"
    selector += "<ul id=\"locale-switch\">"
    available_locales.each do |locale|
      if locale != I18n.locale.to_s
        selector += "<li>"
        selector += link_to image_tag("s.gif", {:class => "flag_" + locale, :alt => locale, :width => 20, :height => 12}) + " " +
                    I18n.t('meta.language_name', :locale => locale.to_sym),
                    login_url(:locale => locale)
        selector += "</li>"
      end
    end
    selector += "</ul>"
    selector += "</li>"
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

  def sprite_tag(klass, options = {})
    image_tag("s.gif", {:class => klass, :alt => klass}.merge(options))
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
    I18n.t('helpers.format.uptime', :days => days, :hours => hours, :minutes => minutes, :seconds => num_seconds)
  end
end
