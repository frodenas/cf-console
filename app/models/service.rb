class Service
  def initialize(cf_client)
    @cf_client = cf_client
  end

  def find_all_services()
    @cf_client.list_services || []
  end

  def find(name)
    raise I18n.t('services.model.name_blank') if name.blank?
    @cf_client.service_info(name) || nil
  end

  def create(name, ss)
    raise I18n.t('services.model.name_blank') if name.blank?
    raise I18n.t('services.model.name_invalid', :name => name) if (name =~ /^[\w-]+$/).nil?
    raise I18n.t('services.model.ss_blank') if ss.blank?
    @cf_client.create_service(ss, name)
  end

  def delete(name)
    raise I18n.t('services.model.name_blank') if name.blank?
    @cf_client.delete_service(name)
  end
end