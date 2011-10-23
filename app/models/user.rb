class User
  def initialize(cf_conn)
    @cf_conn = cf_conn
  end

  def find_all_users()
    return @cf_conn.users || []
  end

  def find(username)
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
    if !user_info.nil? && user_info[:admin] == true
      return true
    else
      return false
    end
  end

  def create(username, password)
    if username.nil? || username.empty?
      raise "Email cannot be blank"
    end
    if password.nil? || password.empty?
      raise "Password cannot be blank"
    end
    @cf_conn.add_user(username, password)
  end

  def delete(username)
    if username.nil? || username.empty?
      raise "Email cannot be blank"
    end
    @cf_conn.delete_user(username)
  end
end