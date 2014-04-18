# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'silw/version'

Gem::Specification.new do |spec|
  spec.name          = "silw"
  spec.version       = Silw::VERSION
  spec.authors       = ["Florin T.PATRASCU"]
  spec.email         = ["florin.patrascu@gmail.com"]
  spec.summary       = %q{SImple Linux stats Watcher.}
  spec.description   = %q{Read various system stats from local or remote systems and publish them in a simple and configurable dashboard}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  # Gem dependencies for development
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_dependency 'rack', '~> 1.4.1'
  spec.add_dependency 'rack-contrib', '~> 1.1.0'
  spec.add_dependency 'rack-cache', '~> 1.1.0'
  spec.add_dependency 'sinatra', '~> 1.3.2'
  spec.add_dependency 'sinatra-contrib', '~> 1.3.1'
  spec.add_dependency 'net-sftp'
  spec.add_dependency 'thor'
  spec.add_dependency 'eventmachine'
  spec.add_dependency 'thin'
  spec.add_dependency 'logger'
  spec.add_dependency 'chronic_duration'
  spec.add_dependency 'logstash-logger'
  # authentication
  spec.add_dependency 'omniauth', '~> 1.0.2'
  spec.add_dependency 'omniauth-browserid', '~> 0.0.1'

  # frontend/views/assets related
  spec.add_dependency 'haml', '~> 3.1.4'
  spec.add_dependency 'i18n', '~> 0.6.0'
  spec.add_dependency 'tilt', '~> 1.4'

end
