require 'net/sftp'

# CPU info - report the total CPU usage for a remote system.
# For more details about 'proc/stat' see:
# - http://www.linuxhowtos.org/System/procstat.htm
# 
# @return - a JSON containing the total CPU usage as a percentage 
module Silw
  module Plugins
    class Cpu
      attr_accessor :cpu_stats
      CpuStats = Struct.new :user, :nice, :system, :idle, :iowait, 
                            :irq, :softirq, :steal, :guest, :guest_nice,
                            :total

      def run(args)
        host = args[:at]

        if fixture_cpu_at_t0 = args[:fixture_cpu_at_t0] and fixture_cpu_at_t1 = args[:fixture_cpu_at_t1]
          cpu_stats = parse_stats File.read(fixture_cpu_at_t0), File.read(fixture_cpu_at_t1) 
        else
          cpu_at_t0 = get_stat(host)
          sleep 0.5
          cpu_at_t1 = get_stat(host)
          cpu_stats = parse_stats cpu_at_t0, cpu_at_t1 
        end

        {:host => host, :cpu => cpu_stats}
      end

      private #methods
      def proc_stat_struct(cpu_times)
        parts = cpu_times.split(/\n/).first.split
        times = parts[1..-1].map(&:to_i)
        CpuStats[*times].tap {|r| r[:total] = times.reduce(:+)}
      end

      def parse_stats(cpu_at_t0, cpu_at_t1)
        cpu0 = proc_stat_struct cpu_at_t0
        cpu1 = proc_stat_struct cpu_at_t1
        idle  = cpu1.idle - cpu0.idle
        total = cpu1.total - cpu0.total
        usage = total - idle
        # {:cpu_usage => ("%.1f%%" % (100.0 * usage / total))}
        {:usage => (100.0 * usage / total).round}
      end

      def get_stat(remote, opts={})
        Net::SFTP.start(remote, @username, :keys => @pub_key ) do |scp|
          return scp.download!('/proc/stat').split('\n').first
        end
      end
    end
  end
end