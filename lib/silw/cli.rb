require 'eventmachine'
require 'chronic_duration'
require "yaml"
require "thor"
require "silw"
require "silw/agent"

Dir["./lib/**/*.rb"].each{|f| require f}

module Silw
  class Cli < Thor
    include Thor::Actions

    method_option :config, :default => Silw::CONFIG_PATH, :aliases => "-c", :desc => "The Silw config file"
    method_option :server, :aliases => "-s", :desc => "host name of the server to be monitored"
    method_option :user, :aliases => "-u", :desc => "user that can be used with a specified public key"
    method_option :key, :aliases => "-k", :desc => "a public key that works for the user specified. Example: ~/.ssh/id_dsa"
    method_option :port, :aliases => "-p", :desc => "port number for the server (overriding the silw.yaml config file)"
    method_option :help, :aliases => "-h", :desc => "showing the available command line options"
    def initialize(*args); super; end

    desc "exec plugin1 plugin2 [plugin3]", "execute sequentially the plugins specified"
    def exec(*plugins)
      opts = Silw::Cli::load_config(options[:config])
      opts[:authentication][:username] = options[:user] if options[:user]
      opts[:authentication][:password] = options[:key] if options[:key]
      host = options[:server]
      logstash_config = opts[:logstash]
      logger = PLUGINS_LOG

      unless logstash_config.nil?
        logstash_host = logstash_config[:server] || '0.0.0.0'
        logstash_port = (logstash_config[:port] || '5229, tcp').split(/\W+/)
        logger = LogStashLogger.new logstash_host, logstash_port[0], logstash_port[1].to_sym
      end

      Authenticate.with(opts) do |user|
        plugins.each do |n|
          info = user.run(n.to_sym, :at => host).to_json
          logger.info info
          puts info
        end
      end
    end

    desc "info", "server info"
    def info
      if pid = Cli.get_pid
        puts "SILW process info:"
        puts "  pid: #{Cli.get_pid}"
      else
        puts "SILW server is not running."
      end
    end

    # start a simple server for publishing the stats collected. The stats
    # are those specified by the silw.yaml config file.
    desc "server start|stop", "start or stop a Sinatra-based SILW server"
    def server(cmd)
      if cmd =~ /^start/
        fork do
          EM.run do
            app_config      = Silw::Cli::load_config(options[:config])
            hosts           = app_config[:monitoring]
            app_container   = 'thin'
            host            = '0.0.0.0'
            port            = ENV['PORT'] || app_config[:server][:port]
            agents          = {}
            logstash_config = app_config[:logstash]
            logger          = PLUGINS_LOG

            unless logstash_config.nil?
              logstash_host = logstash_config[:server] || '0.0.0.0'
              logstash_port = (logstash_config[:port] || '5229, tcp').split(/\W+/)
              logger = LogStashLogger.new logstash_host, logstash_port[0], logstash_port[1].to_sym
            end

            app = Sinatra.new(Server)
            app.set silw_config: app_config
            app.set agents: agents
            app.use ::Rack::CommonLogger, LOGFILE

            $stdout.reopen(LOGFILE)
            $stderr.reopen(LOGFILE)

            begin
              # Start the background monitoring tasks here ... if any defined?!
              hosts.keys.each do |host|
                EM.add_periodic_timer(ChronicDuration.parse(hosts[host][:freq])) do
                  Authenticate.with(app_config) do |user|
                    agent = Agent.new host                    
                    hosts[host][:plugins].scan(/(\w+)/).flatten.each do |n|
                      agent.collect_data n.to_sym, user.run(n.to_sym, :at => host), logger
                    end
                    agents[host] = agent
                  end
                end
              end

              dispatch = Rack::Builder.app do
                map '/' do
                  run app
                end
              end

              Rack::Server.start({
                app:    dispatch,
                server: app_container,
                Host:   host,
                Port:   port
              })
              
              File.open(PIDFILE, 'w') { |f| f << Process.pid }
              # CTRL-C? Should we do something about that?
              Signal.trap('INT') do
                puts
                Cli.stop
              end

              # stopped using the script itself?
              Signal.trap('HUP') do
                puts
                Cli.stop
              end

            rescue => e
              LOG.error "#{e} at #{e.backtrace.join("\n")}"
              # $stderr.puts "Cannot load the silw server; error: #{$!.message}"
              exit 1    
            end        
          end    
        end # fork     
      else
        Cli.stop
      end
    end
    
    def self.stop
      pid = self.get_pid
      if pid
        Process.kill('HUP', pid)
        File.unlink(PIDFILE)
      else
        exit -1
      end
    end

    def self.get_pid
      if File.exists?(PIDFILE)
        pid = File.read(PIDFILE).to_i
        pid > 0 ? pid : nil
      end
    end

    private    
    def self.load_config(path=CONFIG_PATH)
      config_file = File.expand_path(path)
      if File.exists?(config_file)
        ::YAML.load_file config_file
      else
        {:authentication => {:username => 'nobody', :password => '~/.ssh/id_dsa'}}
      end
    end
  end
end