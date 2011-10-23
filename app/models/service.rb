class Service
  def initialize(cf_conn)
    @cf_conn = cf_conn
  end

  def find_all_services()
    return @cf_conn.services || []
  end

  def find(name)
    service_info = nil
    services = find_all_services()
    services.each do |service_item|
      if service_item[:name] == name
        service_info = service_item
        break
      end
    end
    return service_info
  end

  def create(name, ss)
    if name.nil? || name.empty?
      raise "Name cannot be blank"
    end
    if (name =~ /^[\w-]+$/).nil?
      raise "Invalid service name: \"" + name + "\". Must contain only word characters (letter, number, underscore)."
    end
    if ss.nil? || ss.empty?
      raise "Service cannot be blank"
    end
    @cf_conn.create_service(ss, name)
  end

  def delete(name)
    if name.nil? || name.empty?
      raise "Name cannot be blank"
    end
    @cf_conn.delete_service(name)
  end
end