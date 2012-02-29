require 'rubygems'
require 'sinatra'

get '/' do
  host = ENV['VCAP_APP_HOST']
  port = ENV['VCAP_APP_PORT']
  res = ''
  for key in ENV.keys
    res += "<b>" + key + "</b>" + "=" + ENV[key] + "<br/>\n"
  end  
  "<h2>CloudFoundry Instance running at #{host}:#{port}</h2><br /><h2>Environment:</h2>\n" + res
end