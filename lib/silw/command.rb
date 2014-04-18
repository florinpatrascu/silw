module Silw
  class Command
    def initialize(auth_options={})
      @username = auth_options[:authentication][:username]
      @password = auth_options[:authentication][:password]
      pub_key = File.expand_path(@password)
      if File.exists?(pub_key)
        @pub_key = pub_key
      end
      raise RuntimeError unless @password or @pub_key
    end

    # see: http://ruby-metaprogramming.rubylearning.com/html/ruby_metaprogramming_3.html
    def run(command, remotes={})
      plugin = Kernel.const_get("Silw::Plugins::#{command.capitalize}").new
      plugin.instance_variable_set(:@username, @username)
      if @pub_key
        plugin.instance_variable_set(:@pub_key, @pub_key)
      else
        plugin.instance_variable_set(:@password, @password)
      end
      plugin.run(remotes)
    end
  end
end