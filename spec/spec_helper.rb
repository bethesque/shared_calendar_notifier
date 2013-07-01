require 'vcr'
require 'pathname'
require 'mail'

lib_dir = File.join(File.dirname(__FILE__), "..", "lib")
$:.unshift(lib_dir)

require 'shared_calendar_notifier'

Mail.defaults do
  delivery_method :test
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :fakeweb
  c.configure_rspec_metadata!
end

#For VCR
RSpec.configure do |c|
  c.treat_symbols_as_metadata_keys_with_true_values = true
  c.include Mail::Matchers
end
