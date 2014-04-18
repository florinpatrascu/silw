require 'net/sftp'
require 'json'

module Silw
  module Plugins

    # verify the disk usage on a remote host using the contents of
    # /proc/diskstats file.
    # See: https://www.kernel.org/doc/Documentation/ABI/testing/procfs-diskstats
    #
    # return a JSON containing the disk [read, write] stats
    class Diskio
      attr_accessor :diskstats

      def run(args)
        host = args[:at]

        if fixture_name = args[:fixture]
          diskstats = parse_diskstats File.read(fixture_name)
        else
          diskio_then = parse_diskstats get_diskstats(host)
          sleep 1
          diskio_now = parse_diskstats get_diskstats(host)

          # disk [read, write] stats
          diskstats = [diskio_now[0]-diskio_then[0], diskio_now[1]-diskio_then[1]]
        end

        {:host => host, :diskio => diskstats}
      end

      private
      def parse_diskstats(txt)
        diskstats = txt.split(/\n/).collect { |x| x.strip }
        rowcount = diskstats.count

        rowcount.times do |i|
           diskstats[i] = diskstats[i].gsub(/\s+/m, ' ').split(' ')
         end

         columns_array = []
         rowcount.times do |i|
           columns_array << [diskstats[i][3],diskstats[i][7]]
         end

         columncount = columns_array[0].count

         total_read_writes = []
         columncount.times do |i|
           total_read_writes[i] = 0
         end

         columncount.times do |j|
           rowcount.times do |k|
             total_read_writes[j] = columns_array[k][j].to_i + total_read_writes[j]
           end
         end

        total_read_writes
      end


      def get_diskstats(remote)
        Net::SFTP.start(remote, @username, :keys => @pub_key) do |scp|
          return scp.download!('/proc/diskstats')
        end
      end
    end
  end
end