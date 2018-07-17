# frozen_string_literal: true

require_relative '../../../libraries/helpers/config_carbon'

describe SnuGraphiteCookbook::Helpers::ConfigCarbon do
  it 'sets a default cache config' do
    expect(described_class::DEFAULT_CACHE_CONFIG).to eq(
      enable_logrotation: true,
      user: '%<user>s',
      max_cache_size: 'inf',
      max_updates_per_second: 100,
      max_creates_per_minute: 200,
      line_receiver_interface: '0.0.0.0',
      line_receiver_port: 2003,
      udp_receiver_port: 2003,
      pickle_receiver_port: 2004,
      enable_udp_listener: true,
      cache_query_port: 7002,
      cache_write_strategy: 'sorted',
      use_flow_control: true,
      log_updates: false,
      log_cache_hits: false,
      whisper_autoflush: false,
      local_data_dir: '%<storage_path>s/whisper'
    )
  end

  it 'sets a default relay config' do
    expect(described_class::DEFAULT_RELAY_CONFIG).to eq({})
  end

  it 'sets a default aggregator config' do
    expect(described_class::DEFAULT_AGGREGATOR_CONFIG).to eq({})
  end

  resource_class = Class.new do
    include SnuGraphiteCookbook::Helpers::ConfigCarbon

    def user
      'graphite'
    end

    def storage_path
      '/opt/graphite/storage'
    end
  end
  describe resource_class do
    describe '#default_config_for' do
      let(:service) { nil }
      let(:res) { described_class.new.default_config_for(service) }

      context 'the cache service' do
        let(:service) { :cache }

        it 'returns the expected result hash' do
          expected = {
            enable_logrotation: true,
            user: 'graphite',
            max_cache_size: 'inf',
            max_updates_per_second: 100,
            max_creates_per_minute: 200,
            line_receiver_interface: '0.0.0.0',
            line_receiver_port: 2003,
            udp_receiver_port: 2003,
            pickle_receiver_port: 2004,
            enable_udp_listener: true,
            cache_query_port: 7002,
            cache_write_strategy: 'sorted',
            use_flow_control: true,
            log_updates: false,
            log_cache_hits: false,
            whisper_autoflush: false,
            local_data_dir: '/opt/graphite/storage/whisper'
          }
          expect(res).to eq(expected)
        end
      end

      context 'the relay service' do
        let(:service) { :relay }

        it 'returns the expected result hash' do
          expect(res).to eq({})
        end
      end

      context 'the aggregator service' do
        let(:service) { :aggregator }

        it 'returns the expected result hash' do
          expect(res).to eq({})
        end
      end
    end
  end

  describe SnuGraphiteCookbook::Helpers::ConfigCarbon::Config do
    let(:test_obj) do
      described_class.new(
        cache: {
          string_pants: 'test1',
          integer_pants: 123,
          boolean_pants: true,
          more_boolean_pants: false
        },
        relay: {
          string_relay: 'test2',
          integer_relay: 456,
          boolean_relay: true,
          more_boolean_relay: false
        },
        aggregator: {
          string_aggr: 'test3',
          integer_aggr: 789,
          boolean_aggr: true,
          more_boolean_aggr: false
        }
      )
    end

    describe '#initialize' do
      it 'saves the config hash' do
        expected = {
          cache: {
            string_pants: 'test1',
            integer_pants: 123,
            boolean_pants: true,
            more_boolean_pants: false
          },
          relay: {
            string_relay: 'test2',
            integer_relay: 456,
            boolean_relay: true,
            more_boolean_relay: false
          },
          aggregator: {
            string_aggr: 'test3',
            integer_aggr: 789,
            boolean_aggr: true,
            more_boolean_aggr: false
          }
        }
        expect(test_obj.send(:config)).to eq(expected)
      end
    end

    describe '#to_s' do
      it 'returns the expected carbon.conf string' do
        expected = <<-EXP.gsub(/^ +/, '')
          # This file is managed by Chef.
          # Any changes to it will be overwritten.
          [cache]
          STRING_PANTS = test1
          INTEGER_PANTS = 123
          BOOLEAN_PANTS = True
          MORE_BOOLEAN_PANTS = False

          [relay]
          STRING_RELAY = test2
          INTEGER_RELAY = 456
          BOOLEAN_RELAY = True
          MORE_BOOLEAN_RELAY = False

          [aggregator]
          STRING_AGGR = test3
          INTEGER_AGGR = 789
          BOOLEAN_AGGR = True
          MORE_BOOLEAN_AGGR = False
        EXP
        expect(test_obj.to_s).to eq(expected)
      end
    end

    describe '#inspect' do
      it 'returns the expected carbon.conf string' do
        expected = <<-EXP.gsub(/^ +/, '')
          # This file is managed by Chef.
          # Any changes to it will be overwritten.
          [cache]
          STRING_PANTS = test1
          INTEGER_PANTS = 123
          BOOLEAN_PANTS = True
          MORE_BOOLEAN_PANTS = False

          [relay]
          STRING_RELAY = test2
          INTEGER_RELAY = 456
          BOOLEAN_RELAY = True
          MORE_BOOLEAN_RELAY = False

          [aggregator]
          STRING_AGGR = test3
          INTEGER_AGGR = 789
          BOOLEAN_AGGR = True
          MORE_BOOLEAN_AGGR = False
        EXP
        expect(test_obj.inspect).to eq(expected)
      end
    end

    describe '#body' do
      it 'returns the expected body string' do
        expected = <<-EXP.gsub(/^ +/, '')
          [cache]
          STRING_PANTS = test1
          INTEGER_PANTS = 123
          BOOLEAN_PANTS = True
          MORE_BOOLEAN_PANTS = False

          [relay]
          STRING_RELAY = test2
          INTEGER_RELAY = 456
          BOOLEAN_RELAY = True
          MORE_BOOLEAN_RELAY = False

          [aggregator]
          STRING_AGGR = test3
          INTEGER_AGGR = 789
          BOOLEAN_AGGR = True
          MORE_BOOLEAN_AGGR = False
        EXP
        expect(test_obj.send(:body)).to eq(expected)
      end
    end

    describe '#to_ini' do
      it 'returns the expected ini object' do
        expected = IniParse.gen do |doc|
          doc.section('cache') do |sect|
            sect.option('STRING_PANTS', 'test1')
            sect.option('INTEGER_PANTS', '123')
            sect.option('BOOLEAN_PANTS', 'True')
            sect.option('MORE_BOOLEAN_PANTS', 'False')
          end
          doc.section('relay') do |sect|
            sect.option('STRING_RELAY', 'test2')
            sect.option('INTEGER_RELAY', '456')
            sect.option('BOOLEAN_RELAY', 'True')
            sect.option('MORE_BOOLEAN_RELAY', 'False')
          end
          doc.section('aggregator') do |sect|
            sect.option('STRING_AGGR', 'test3')
            sect.option('INTEGER_AGGR', '789')
            sect.option('BOOLEAN_AGGR', 'True')
            sect.option('MORE_BOOLEAN_AGGR', 'False')
          end
        end
        expect(test_obj.send(:to_ini).to_ini).to eq(expected.to_ini)
      end
    end

    describe '#header' do
      it 'returns the expected header string' do
        expected = <<-EXP.gsub(/^ +/, '').strip
          # This file is managed by Chef.
          # Any changes to it will be overwritten.
        EXP
        expect(test_obj.send(:header)).to eq(expected)
      end
    end

    describe '#value_for' do
      let(:val) { nil }
      let(:res) { test_obj.send(:value_for, val) }

      context 'a string value' do
        let(:val) { 'something' }

        it 'returns the expected string' do
          expect(res).to eq('something')
        end
      end

      context 'an integer value' do
        let(:val) { 123_456 }

        it 'returns the expected string' do
          expect(res).to eq('123456')
        end
      end

      context 'a true value' do
        let(:val) { true }

        it 'returns the expected string' do
          expect(res).to eq('True')
        end
      end

      context 'a false value' do
        let(:val) { false }

        it 'returns the expected string' do
          expect(res).to eq('False')
        end
      end
    end

    describe '#key_for' do
      let(:key) { nil }
      let(:res) { test_obj.send(:key_for, key) }

      context 'a one-word key' do
        let(:key) { :thing }

        it 'returns the expected string' do
          expect(res).to eq('THING')
        end
      end

      context 'a multi-word key' do
        let(:key) { :some_config_stuff }

        it 'returns the expected string' do
          expect(res).to eq('SOME_CONFIG_STUFF')
        end
      end
    end
  end
end
