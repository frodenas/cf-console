source 'http://rubygems.org'

gem 'rails', '3.2.0'
gem 'haml', '~> 3.1.4'
gem 'coderay', '~> 1.0.5'
gem 'cloudfoundry-client', '~> 0.2.0'
gem 'configatron', '~> 2.9.0'
gem 'addressable', '~> 2.2.6'
gem 'rubyzip', '~> 0.9.5'
gem 'eventmachine', '~> 1.0.0.beta.4'
gem 'rack-fiber_pool', '~> 0.9.2', :require => 'rack/fiber_pool'
gem 'em-synchrony', '~> 1.0.0', :require => ['em-synchrony', 'em-synchrony/em-http', 'em-synchrony/fiber_iterator']
gem 'em-http-request', '~> 1.0.1', :require => 'em-http'
gem 'thin', '~> 1.3.1'
gem 'i18n-js', '~> 2.1.2'
gem 'routing-filter', '~> 0.3.0'

group :assets do
  gem 'sass-rails', '~> 3.2.3'
  gem 'uglifier', '>= 1.2.2'
  gem 'sprite-factory', '>= 1.4.1'
  gem 'chunky_png', '>= 1.2.5'
end

# RSpec2 needs to be in the :development group to expose generators and rake tasks without having to type RAILS_ENV=test
group :development, :test do
  gem 'rspec-rails', '~> 2.8.1'
end

group :test do
  gem 'webmock', '~> 1.8.0'
  gem 'vcr', '~> 2.0.0.rc2'
  gem 'simplecov', '~> 0.6.1', :require => false
end