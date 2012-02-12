class Service
  def initialize(cf_client)
    @cf_client = cf_client
  end

  def find_all_services()
    return @cf_client.list_services || []
  end

  def find(name)
    raise t('services.model.name_blank') if name.nil? || name.empty?
    return @cf_client.service_info(name) || nil
  end

  def create(name, ss)
    raise t('services.model.name_blank') if name.nil? || name.empty?
    raise t('services.model.name_invalid', :name => name) if (name =~ /^[\w-]+$/).nil?
    raise t('services.model.ss_blank') if ss.nil? || ss.empty?
    @cf_client.create_service(ss, name)
  end

  def delete(name)
    raise t('services.model.name_blank') if name.nil? || name.empty?
    @cf_client.delete_service(name)
  end
end