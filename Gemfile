source 'http://rubygems.org'

gem 'rails',   '3.1.1'
gem 'json',    '~> 1.6.1'
gem 'haml',    '~> 3.1.3'
gem 'vmc',     '~> 0.3.12'
gem 'coderay', '~> 1.0.1'

group :assets do
  gem 'sass-rails',   '~> 3.1.4'
  gem 'uglifier',     '>= 1.0.4'
  #gem 'execjs',       '~> 1.2.9'
  #gem 'therubyracer', '~> 0.9.8'
end

# RSpec2 needs to be in the :development group to expose generators and rake tasks without having to type RAILS_ENV=test
group :development, :test do
  gem "rspec-rails", "~> 2.7.0"
end

group :test do
  gem "webmock", "~> 1.7.7"
  gem "vcr", "~> 2.0.0.beta1"
end