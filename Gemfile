source 'http://rubygems.org'

gem 'rails', '3.2.7'
gem 'haml', '~> 3.1.6'
gem 'coderay', '~> 1.0.7'
gem 'cloudfoundry-client', '~> 0.3.0', :require => 'faraday'
gem 'configatron', '~> 2.9.1'
gem 'addressable', '~> 2.2.8'
gem 'rubyzip', '~> 0.9.9'
gem 'eventmachine', '~> 1.0.0.rc.4'
gem 'rack-fiber_pool', '~> 0.9.2', :require => 'rack/fiber_pool'
gem 'em-synchrony', '~> 1.0.2', :require => ['em-synchrony', 'em-synchrony/em-http', 'em-synchrony/fiber_iterator']
gem 'em-http-request', '~> 1.0.2', :require => 'em-http'
gem 'thin', '~> 1.4.1'
gem 'i18n-js', '~> 2.1.2'
gem 'routing-filter', '~> 0.3.1'

group :assets do
  gem 'sass-rails', '~> 3.2.5'
  gem 'uglifier', '~> 1.2.6'
  gem 'sprite-factory', '~> 1.5.1'
  gem 'chunky_png', '~> 1.2.5'
end

# RSpec2 needs to be in the :development group to expose generators and rake tasks without having to type RAILS_ENV=test
group :development, :test do
  gem "rake", '~> 0.9.2.2'
  gem 'rspec-rails', '~> 2.11.0'
end

group :test do
  gem 'webmock', '~> 1.8.8'
  gem 'vcr', '~> 2.0.0'
  #gem 'simplecov', '~> 0.6.4', :require => false
end