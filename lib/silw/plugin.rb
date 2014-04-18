require "silw/command"

module Silw
  class Plugin < Command
    attr :username, :password, :pub_key

    def run
      puts "implement me"
    end

    def self.inherited(base)
      subclasses << base
    end

    def self.subclasses
      @subclasses ||= []
    end
  end
end