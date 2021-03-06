# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shared_calendar_notifier/version'

Gem::Specification.new do |spec|
  spec.name          = "shared_calendar_notifier"
  spec.version       = SharedCalendarNotifier::VERSION
  spec.authors       = ["Beth"]
  spec.email         = ["beth@bethesque.com"]
  spec.description   = "Sends notifications when events are created in the shared calendar."
  spec.summary       = "See description"
  spec.homepage      = "https://github.com/bethesque/shared_calendar_notifier"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'google-api-client', '~>0.6.0'
  spec.add_dependency 'jwt', '~> 0.1.4'
  spec.add_dependency "activesupport"
  spec.add_dependency "tzinfo", "~> 1.0"
  spec.add_dependency "mail", "~> 2.5"
  spec.add_dependency 'json', '~> 1.7'
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'vcr', '~>2.4'
  spec.add_development_dependency 'fakeweb'
  spec.add_development_dependency "rspec", "~>2.13"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "dotenv"
end
