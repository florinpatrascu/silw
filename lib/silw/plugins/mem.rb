require 'net/sftp'

module Silw
  module Plugins

    # Meminfo - report the memory stats collected from a remote system.
    # For more details about meminfo see this featured article: /proc/meminfo Explained, at:
    #  - http://www.redhat.com/advice/tips/meminfo.html
    #
    # @return - a JSON containing the main memory stats
    class Mem
      attr_accessor :mem

      def run(args)        
        host = args[:at]

        if fixture_name = args[:fixture]
          mem = parse_meminfo File.read(fixture_name)
        else
          mem = parse_meminfo get_meminfo(host)
        end

        {:host => host, :mem => mem}
      end
      
      private
      def parse_meminfo(txt)
        meminfo   = txt.split(/\n/).collect{|x| x.strip}
        memtotal  = meminfo[0].gsub(/[^0-9]/, "").to_f
        memfree   = meminfo[1].gsub(/[^0-9]/, "").to_f
        memactive = meminfo[5].gsub(/[^0-9]/, "").to_f
        {:total => memtotal.round, :active => memactive.round, :free => memfree.round, 
         :usagepercentage => ((memactive * 100) / memtotal).round}
      end

      def get_meminfo(remote, opts={})
        Net::SFTP.start(remote, @username, :keys => @pub_key ) do |scp|
          return scp.download!('/proc/meminfo')
        end
      end
    end
  end
end