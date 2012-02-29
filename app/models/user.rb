class User
  def initialize(cf_client)
    @cf_client = cf_client
  end

  def find_all_users()
    @cf_client.list_users || []
  end

  def find(username)
    raise I18n.t('users.model.email_blank') if username.blank?
    user_info = @cf_client.user_info(username) || nil
    # cc's prior to 31143c1 commit doesn't return the admin flag
    if !user_info.nil? && !user_info.has_key?(:admin)
      user_info = nil
      users = find_all_users()
      users.each do |user_item|
        if user_item[:email] == username
          user_info = user_item
          break
        end
      end
    end
    user_info
  end

  def is_admin?(username)
    user_info = find(username)
    return true if !user_info.nil? && user_info[:admin] == true
    false
  end

  def create(username, password)
    raise I18n.t('users.model.email_blank') if username.blank?
    raise I18n.t('users.model.password_blank') if password.blank?
    @cf_client.create_user(username, password)
  end

  def delete(username)
    raise I18n.t('users.model.email_blank') if username.blank?
    @cf_client.delete_user(username)
  end
end