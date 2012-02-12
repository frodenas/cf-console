class User
  def initialize(cf_client)
    @cf_client = cf_client
  end

  def find_all_users()
    return @cf_client.list_users || []
  end

  def find(username)
    raise t('users.model.email_blank') if username.nil? || username.empty?
    user_info = nil
    users = find_all_users()
    users.each do |user_item|
      if user_item[:email] == username
        user_info = user_item
        break
      end
    end
    return user_info
  end

  def is_admin?(username)
    user_info = find(username)
    return true if !user_info.nil? && user_info[:admin] == true
    return false
  end

  def create(username, password)
    raise t('users.model.email_blank') if username.nil? || username.empty?
    raise t('users.model.password_blank') if password.nil? || password.empty?
    @cf_client.create_user(username, password)
  end

  def delete(username)
    raise t('users.model.email_blank') if username.nil? || username.empty?
    @cf_client.delete_user(username)
  end
end