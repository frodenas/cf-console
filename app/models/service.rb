class Service
  def initialize(cf_client)
    @cf_client = cf_client
  end

  def find_all_services()
    return @cf_client.list_services || []
  end

  def find(name)
    raise "Name cannot be blank" if name.nil? || name.empty?
    return @cf_client.service_info(name) || nil
  end

  def create(name, ss)
    raise "Name cannot be blank" if name.nil? || name.empty?
    raise "Invalid service name: \"" + name + "\". Must contain only word characters (letter, number, underscore)." if (name =~ /^[\w-]+$/).nil?
    raise "Service cannot be blank" if ss.nil? || ss.empty?
    @cf_client.create_service(ss, name)
  end

  def delete(name)
    raise "Name cannot be blank" if name.nil? || name.empty?
    @cf_client.delete_service(name)
  end
end