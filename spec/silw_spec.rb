require 'spec_helper'

module Silw
  describe 'Logger configuration' do
    let (:config_with_logstash)    { ::YAML.load_file(fixture('silw_with_logstash.yaml')) }
    let (:config_without_logstash) { ::YAML.load_file(fixture('silw.yaml')) }

    describe 'with logstah' do
      it 'should have logstash server port and name/address defined' do
        expect(config_with_logstash).to include(:logstash)
        logstash_server_config = config_with_logstash[:logstash]
        expect(logstash_server_config).to include(:host)
        expect(logstash_server_config[:port].split(/\W+/).size).to be 2
        expect(logstash_server_config[:port].split(/\W+/)[1]).to include('udp')
      end
    end
  end

  describe 'Plugins support' do
    let (:config) { ::YAML.load_file(fixture('silw.yaml')) }

    describe Plugins::Mem
    it "should return memory statistics for a given host" do

      Authenticate.with(config) do |user|
        user.should be_instance_of(Command)
        mem_hash = user.run :mem, :at => 'router', :fixture => fixture("mem.txt")
        expect(mem_hash.keys).to include(:host)
        mem = mem_hash[:mem]
        expect(mem.keys).to include(:free)

        # expecting the mem plugin to return memory info in bytes
        expect(mem[:total]).to eq(2_075_624 * 1_024)
      end
    end

    describe Plugins::Cpu do
      it "should return memory statistics for a given host" do

        Authenticate.with(config) do |user|
          user.should be_instance_of(Command)
          cpustats = user.run :cpu, :at => 'router',
                              :fixture_cpu_at_t0 => fixture("cpu_t0.txt"),
                              :fixture_cpu_at_t1 => fixture("cpu_t1.txt")
          expect(cpustats[:cpu][:usage]).not_to be_nil
        end
      end
    end

    describe Plugins::Diskio do
      it 'should return the disk I/O stats for a given host' do
        Authenticate.with(config) do |user|
          user.should be_instance_of(Command)
          diskstats = user.run :diskio, :at => 'router', :fixture => fixture("diskstats.txt")

          expect(diskstats.keys).to include(:host)
          expect(diskstats[:diskio].count).to eq(2)
          expect(diskstats[:diskio][0]).to be_a ::Numeric
        end
      end
    end

    describe "Human-readable conversions" do
      it "should display readable numbers" do
        expect(like_filesize(1_024 ** 0)).to eq "1.0bytes"
        expect(like_filesize(1_024 ** 1)).to eq "1.0KB"
        expect(like_filesize(1_024 ** 2)).to eq "1.0MB"
        expect(like_filesize(1_024 ** 3)).to eq "1.0GB"
        expect(like_filesize(1_024 ** 4)).to eq "1.0TB"
      end
    end
  end
end