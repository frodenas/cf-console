CfConsole::Application.routes.draw do
  root :to => "dashboard#index"

  # Dashboard
  get     'dashboard' => 'dashboard#index', :as => :dashboard

  # Applications
  get     'apps'                                    => 'apps#index',          :as => :apps_info
  post    'apps'                                    => 'apps#create',         :as => :apps_create
  get     'app/:name'                               => 'apps#show',           :as => :app_info
  delete  'app/:name'                               => 'apps#delete',         :as => :app_delete
  put     'app/:name/start'                         => 'apps#start',          :as => :app_start
  put     'app/:name/stop'                          => 'apps#stop',           :as => :app_stop
  put     'app/:name/restart'                       => 'apps#restart',        :as => :app_restart
  put     'app/:name/set_instances'                 => 'apps#set_instances',  :as => :app_set_instances
  put     'app/:name/set_memsize'                   => 'apps#set_memsize',    :as => :app_set_memsize
  put     'app/:name/set_var'                       => 'apps#set_var',        :as => :app_set_var
  put     'app/:name/unset_var'                     => 'apps#unset_var',      :as => :app_unset_var
  put     'app/:name/bind_service'                  => 'apps#bind_service',   :as => :app_bind_service
  put     'app/:name/unbind_service'                => 'apps#unbind_service', :as => :app_unbind_service
  put     'app/:name/map_url'                       => 'apps#map_url',        :as => :app_map_url
  put     'app/:name/unmap_url'                     => 'apps#unmap_url',      :as => :app_unmap_url
  put     'app/:name/update_bits'                   => 'apps#update_bits',    :as => :app_update_bits
  get     'app/:name/download_bits'                 => 'apps#download_bits',  :as => :app_download_bits
  get     'app/:name/files/:instance/:filename'     => 'apps#files',          :as => :app_files
  get     'app/:name/view_file/:instance/:filename' => 'apps#view_file',      :as => :app_view_file

  # Services
  get     'services'       => 'services#index',  :as => :services_info
  post    'services'       => 'services#create', :as => :service_create
  delete  'services/:name' => 'services#delete', :as => :service_delete

  # System Information
  get     'system' => 'system#index', :as => :system_info

  # Users
  get     'users'       => 'users#index',  :as => :users_info
  post    'users'       => 'users#create', :as => :user_create
  delete  'users/:name' => 'users#delete', :as => :user_delete

  # Sessions
  get     'login'  => 'sessions#new',     :as => :login
  post    'login'  => 'sessions#create',  :as => :login
  get     'logout' => 'sessions#destroy', :as => :logout
end