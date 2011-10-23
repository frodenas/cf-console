class UsersController < ApplicationController
  def index
    begin
      user = User.new(@cf_client)
      @users = user.find_all_users()
    rescue Exception => ex
      flash[:alert] = ex.message
    end
  end

  def create
    @email = params[:email].strip.downcase
    @password = params[:password].strip
    @vpassword = params[:vpassword].strip
    if !@email.nil? &&!@email.empty?
      if !@password.nil? && !@password.empty?
        if @password == @vpassword
          begin
            user = User.new(@cf_client)
            user_info = user.find(@email)
            if user_info.nil?
              user.create(@email, @password)
              user_info = user.find(@email)
              if !user_info.nil?
                @new_user = [] << user_info
                flash[:notice] = "User \"" + @email + "\" created"
              else
                flash[:alert] = "An error occurred processing your request, please reload the page and try again."
              end
            else
              flash[:alert] = "User already exists"
            end
          rescue Exception => ex
            flash[:alert] = ex.message
          end
        else
          flash[:alert] = "Passwords do not match"
        end
      else
        flash[:alert] = "Password cannot be blank"
      end
    else
      flash[:alert] = "Email cannot be blank"
    end
    respond_to do |format|
      format.html { redirect_to users_info_url }
      format.js { flash.discard }
    end
  end

  def delete
    @email = Base64.decode64(params[:name])
    begin
      user = User.new(@cf_client)
      user.delete(@email)
      flash[:notice] = "User \"" + @email + "\" deleted"
    rescue Exception => ex
      flash[:alert] = ex.message
    end
    respond_to do |format|
      format.html { redirect_to users_info_url }
      format.js { flash.discard }
    end
  end
end