source 'http://rubygems.org'

gem 'rails',   '3.1.3'
gem 'haml',    '~> 3.1.4'
gem 'coderay', '~> 1.0.5'
gem 'cloudfoundry-client', '~> 0.1.1'
gem 'configatron', '~> 2.9.0'
gem 'addressable', '~> 2.2.6'
gem 'rubyzip', '~> 0.9.5'

group :assets do
  gem 'sass-rails',   '~> 3.1.5'
  gem 'uglifier',     '>= 1.2.1'
end

# RSpec2 needs to be in the :development group to expose generators and rake tasks without having to type RAILS_ENV=test
group :development, :test do
  gem "rspec-rails", "~> 2.7.0"
end

group :test do
  gem "webmock", "~> 1.7.8"
  gem "vcr", "~> 2.0.0.rc1"
end