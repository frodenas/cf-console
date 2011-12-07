class System
  def initialize(cf_client)
    @cf_client = cf_client
  end

  def find_account_info()
    return @cf_client.cloud_info || {}
  end

  def find_all_frameworks()
    info = find_account_info()
    return info[:frameworks] || {}
  end

  def find_all_runtimes()
    # FIXME
    # Return runtimes from info Hash instead of runtimes_info Hash as there's more much runtime information
    # Info gets runtime information from staged plugins's
    # Runtime_info gets runtime information from cloud_controller.yml
    runtimes = @cf_client.cloud_runtimes_info || {}

    runtimes = {}
    frameworks = find_all_frameworks()
    frameworks.each do |fwk_name, fwk_data|
      next unless fwk_data[:runtimes]
      fwk_data[:runtimes].each { |r| runtimes[r[:name]] = r}
    end
    return runtimes
  end

  def find_all_system_services()
    return @cf_client.cloud_services_info || {}
  end

  def find_available_memory()
    info = find_account_info()
    usage = info[:usage]
    limits = info[:limits]
    return 0 unless usage and limits

    available_memory = limits[:memory].to_i - usage[:memory].to_i
    return available_memory
  end
end