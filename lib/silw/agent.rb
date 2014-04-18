module Silw
  class Agent
    attr_accessor :host, :plugins, :time

    def initialize(host='')
      @host = host
      @plugins = {}
    end
    
    def collect_data(plugin_name, data={}, logger=nil)
      logger.info data.to_json unless logger.nil?
      @plugins[plugin_name]=data[plugin_name]
      @time=Time.now
      self
    end
  end
end