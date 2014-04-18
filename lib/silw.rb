$:.unshift File.dirname(__FILE__)
require "rubygems"
require 'sinatra'
require 'haml'
require 'rack/contrib'
require 'rack/cache'

require "silw/version"
require "silw/plugin"
require "silw/command"
require "silw/helpers"
require "silw/server"

module Silw
  LOCALHOST   = "localhost"
  MY_KEY      = '~/.ssh/id_dsa'
  CONFIG_PATH = '~/silw.yaml'

  Dir.chdir(File.expand_path(File.join("silw/plugins"), File.dirname(__FILE__))) do
    Dir.entries(".").each do |f|
      next if f[0..0].eql?(".")
      require "silw/plugins/#{f}"
    end
  end

  class Authenticate
    def self.with(auth_options, &block)      
      cmd = Command.new(auth_options)
      if block_given?
        block.call(cmd)
      end
      cmd
    end
  end
end
