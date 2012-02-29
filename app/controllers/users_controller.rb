class UsersController < ApplicationController
  before_filter :require_admin

  def index
    begin
      user = User.new(@cf_client)
      @users = user.find_all_users()
    rescue Exception => ex
      flash[:alert] = ex.message
    end
  end

  def create
    @email = params[:email]
    @password = params[:password]
    @vpassword = params[:vpassword]
    if @email.blank?
      flash[:alert] = I18n.t('users.controller.email_blank')
    elsif @password.blank?
      flash[:alert] = I18n.t('users.controller.password_blank')
    elsif @password != @vpassword
      flash[:alert] = I18n.t('users.controller.passwords_match')
    else
      begin
        @email = @email.strip.downcase
        @password = @password.strip
        user = User.new(@cf_client)
        begin
          user_info = user.find(@email)
        rescue
          user_info = nil
        end
        if user_info.nil?
          user.create(@email, @password)
          user_info = user.find(@email)
          @new_user = [] << user_info
          flash[:notice] = I18n.t('users.controller.user_created', :email => @email)
        else
          flash[:alert] = I18n.t('users.controller.already_exists')
        end
      rescue Exception => ex
        flash[:alert] = ex.message
      end
    end
    respond_to do |format|
      format.html { redirect_to users_info_url }
      format.js { flash.discard }
    end
  end

  def delete
    @email = params[:name]
    if @email.blank?
      flash[:alert] = I18n.t('users.controller.email_blank')
    else
      begin
        @email = Base64.decode64(@email)
        user = User.new(@cf_client)
        user.delete(@email)
        flash[:notice] = I18n.t('users.controller.user_deleted', :email => @email)
      rescue Exception => ex
        flash[:alert] = ex.message
      end
    end
    respond_to do |format|
      format.html { redirect_to users_info_url }
      format.js { flash.discard }
    end
  end
end