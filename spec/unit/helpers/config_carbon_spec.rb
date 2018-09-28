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
end
