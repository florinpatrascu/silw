SPEC_DIR = File.dirname(__FILE__)
lib_path = File.expand_path("#{SPEC_DIR}/../lib")
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)

require "bundler/setup"
require 'rack/test'
require "silw"
require "yaml"

SILW_ENV = ENV['SILW_ENV'] || 'test'
Dir["./lib/**/*.rb"].each{|f| require f}

def fixture(name)
  File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', name))
end
