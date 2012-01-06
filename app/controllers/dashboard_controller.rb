require 'utils'

class DashboardController < ApplicationController
  def index
    begin
      # Account
      system = System.new(@cf_client)
      account_info = system.find_account_info()
      @account_apps_inuse = account_info[:usage][:apps]
      @account_apps_total =  account_info[:limits][:apps]
      @account_apps_unused = @account_apps_total - @account_apps_inuse
      @account_mem_inuse = account_info[:usage][:memory]
      @account_mem_total = account_info[:limits][:memory]
      @account_mem_unused = @account_mem_total - @account_mem_inuse
      @account_services_inuse = account_info[:usage][:services]
      @account_services_total = account_info[:limits][:services]
      @account_services_unused = @account_services_total - @account_services_inuse

      # Applications
      app = App.new(@cf_client)
      apps_states = app.find_all_states() || []
      @apps_states = apps_states.to_json

      # Instances
      instances_states = {}
      apps = app.find_all_apps()
      Utils::FiberedIterator.each(apps, configatron.reactor_iterator.concurrency) do |app_item|
        app_info = app.find(app_item[:name])
        app_info[:instances_states].each do |instance_states|
          if !instances_states[instance_states[:label]]
            instances_states[instance_states[:label]] = instance_states
          else
            instances_states[instance_states[:label]][:data] += instance_states[:data]
          end
        end
      end
      @instances_states = "["
      instances_states.each do |state_key, state_value|
        @instances_states += "{'label': '" + state_value[:label] + "', 'color': '" + state_value[:color] + "', 'data': " + state_value[:data].to_s + "}, "
      end
      @instances_states += "]"

      # Types of application
      apps_types = {}
      apps.each do |app_item|
        app_type = app_item[:staging][:model]
        apps_types[app_type] = apps_types[app_type] ? apps_types[app_type] + 1 : 1
      end
      @apps_types = "["
      apps_types.each do |type_key, type_value|
        @apps_types += "{'label': '" + type_key.capitalize + "', 'data': " + type_value.to_s + "}, "
      end
      @apps_types += "]"
    rescue Exception => ex
      flash[:alert] = ex.message
    end
  end
end
