require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = "spec/fixtures"
  c.hook_into :webmock
  c.default_cassette_options = {:record => :none}
  c.allow_http_connections_when_no_cassette = false
end