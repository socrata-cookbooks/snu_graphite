# frozen_string_literal: true

require_relative '../resources'

describe 'resources::snu_graphite_config_carbon' do
  include_context 'resources'

  let(:resource) { 'snu_graphite_config_carbon' }

  %i[
    service_name graphite_path storage_path user group path config fake
  ].each do |p|
    let(p) { nil }
  end
  let(:properties) do
    {
      service_name: service_name,
      graphite_path: graphite_path,
      storage_path: storage_path,
      user: user,
      group: group,
      path: path,
      config: config,
      fake: fake
    }
  end
  let(:name) { 'cache' }

  shared_context 'the :create action' do
  end

  %i[remove].each do |a|
    shared_context "the :#{a} action" do
      let(:action) { a }
    end
  end

  shared_context 'all default properties' do
  end

  {
    graphite_path: '/tmp/graph',
    storage_path: '/tmp/store',
    user: 'fauxhai',
    group: 'fauxhai',
    path: '/tmp/cc.conf',
    config: { pants: 'test' },
    fake: 'fake'
  }.each do |p, v|
    shared_context "an overridden #{p} property" do
      let(p) { v }
    end
  end

  shared_examples_for 'any platform' do
    context 'the :create action' do
      include_context description

      shared_examples_for 'any service' do
        shared_examples_for 'any property set' do
          it 'creates the config directory' do
            dir = if path.nil?
                    "#{graphite_path || '/opt/graphite'}/conf"
                  else
                    '/tmp'
                  end
            expect(chef_run).to create_directory(dir)
              .with(owner: user || 'graphite',
                    group: group || 'graphite',
                    mode: '0755',
                    recursive: true)
          end

          it 'creates the carbon.conf' do
            f = path || "#{graphite_path || '/opt/graphite'}/conf/carbon.conf"
            expect(chef_run).to create_file(f)
              .with(owner: user || 'graphite',
                    group: group || 'graphite',
                    mode: '0644',
                    sensitive: true)
          end
        end

        context 'all default properties' do
          include_context description

          it_behaves_like 'any property set'
        end

        %w[graphite_path storage_path user group path config fake].each do |p|
          context "an overridden #{p} property" do
            include_context description

            it_behaves_like 'any property set'
          end
        end
      end

      context 'the cache service' do
        it_behaves_like 'any service'

        context 'all default properties' do
          include_context description

          it 'renders the expected carbon.conf content' do
            expected = <<-EXP.gsub(/^ +/, '')
              # This file is managed by Chef.
              # Any changes to it will be overwritten.
              [cache]
              ENABLE_LOGROTATION = True
              USER = graphite
              MAX_CACHE_SIZE = inf
              MAX_UPDATES_PER_SECOND = 100
              MAX_CREATES_PER_MINUTE = 200
              LINE_RECEIVER_INTERFACE = 0.0.0.0
              LINE_RECEIVER_PORT = 2003
              UDP_RECEIVER_PORT = 2003
              PICKLE_RECEIVER_PORT = 2004
              ENABLE_UDP_LISTENER = True
              CACHE_QUERY_PORT = 7002
              CACHE_WRITE_STRATEGY = sorted
              USE_FLOW_CONTROL = True
              LOG_UPDATES = False
              LOG_CACHE_HITS = False
              WHISPER_AUTOFLUSH = False
              LOCAL_DATA_DIR = /opt/graphite/storage/whisper
            EXP
            expect(chef_run).to create_file('/opt/graphite/conf/carbon.conf')
              .with(content: expected)
          end
        end

        context 'an overridden graphite_path property' do
          include_context description

          it 'renders the expected carbon.conf content' do
            expected = <<-EXP.gsub(/^ +/, '')
              # This file is managed by Chef.
              # Any changes to it will be overwritten.
              [cache]
              ENABLE_LOGROTATION = True
              USER = graphite
              MAX_CACHE_SIZE = inf
              MAX_UPDATES_PER_SECOND = 100
              MAX_CREATES_PER_MINUTE = 200
              LINE_RECEIVER_INTERFACE = 0.0.0.0
              LINE_RECEIVER_PORT = 2003
              UDP_RECEIVER_PORT = 2003
              PICKLE_RECEIVER_PORT = 2004
              ENABLE_UDP_LISTENER = True
              CACHE_QUERY_PORT = 7002
              CACHE_WRITE_STRATEGY = sorted
              USE_FLOW_CONTROL = True
              LOG_UPDATES = False
              LOG_CACHE_HITS = False
              WHISPER_AUTOFLUSH = False
              LOCAL_DATA_DIR = /tmp/graph/storage/whisper
            EXP
            expect(chef_run).to create_file('/tmp/graph/conf/carbon.conf')
              .with(content: expected)
          end
        end

        context 'an overridden storage_path property' do
          include_context description

          it 'renders the expected carbon.conf content' do
            expected = <<-EXP.gsub(/^ +/, '')
              # This file is managed by Chef.
              # Any changes to it will be overwritten.
              [cache]
              ENABLE_LOGROTATION = True
              USER = graphite
              MAX_CACHE_SIZE = inf
              MAX_UPDATES_PER_SECOND = 100
              MAX_CREATES_PER_MINUTE = 200
              LINE_RECEIVER_INTERFACE = 0.0.0.0
              LINE_RECEIVER_PORT = 2003
              UDP_RECEIVER_PORT = 2003
              PICKLE_RECEIVER_PORT = 2004
              ENABLE_UDP_LISTENER = True
              CACHE_QUERY_PORT = 7002
              CACHE_WRITE_STRATEGY = sorted
              USE_FLOW_CONTROL = True
              LOG_UPDATES = False
              LOG_CACHE_HITS = False
              WHISPER_AUTOFLUSH = False
              LOCAL_DATA_DIR = /tmp/store/whisper
            EXP
            expect(chef_run).to create_file('/opt/graphite/conf/carbon.conf')
              .with(content: expected)
          end
        end

        context 'an overridden user property' do
          include_context description

          it 'renders the expected carbon.conf content' do
            expected = <<-EXP.gsub(/^ +/, '')
              # This file is managed by Chef.
              # Any changes to it will be overwritten.
              [cache]
              ENABLE_LOGROTATION = True
              USER = fauxhai
              MAX_CACHE_SIZE = inf
              MAX_UPDATES_PER_SECOND = 100
              MAX_CREATES_PER_MINUTE = 200
              LINE_RECEIVER_INTERFACE = 0.0.0.0
              LINE_RECEIVER_PORT = 2003
              UDP_RECEIVER_PORT = 2003
              PICKLE_RECEIVER_PORT = 2004
              ENABLE_UDP_LISTENER = True
              CACHE_QUERY_PORT = 7002
              CACHE_WRITE_STRATEGY = sorted
              USE_FLOW_CONTROL = True
              LOG_UPDATES = False
              LOG_CACHE_HITS = False
              WHISPER_AUTOFLUSH = False
              LOCAL_DATA_DIR = /opt/graphite/storage/whisper
            EXP
            expect(chef_run).to create_file('/opt/graphite/conf/carbon.conf')
              .with(content: expected)
          end
        end

        context 'an overridden config property' do
          include_context description

          it 'renders the expected carbon.conf content' do
            expected = <<-EXP.gsub(/^ +/, '')
              # This file is managed by Chef.
              # Any changes to it will be overwritten.
              [cache]
              PANTS = test
            EXP
            expect(chef_run).to create_file('/opt/graphite/conf/carbon.conf')
              .with(content: expected)
          end
        end

        context 'an overridden fake property' do
          include_context description

          it 'renders the expected carbon.conf content' do
            expected = <<-EXP.gsub(/^ +/, '')
              # This file is managed by Chef.
              # Any changes to it will be overwritten.
              [cache]
              ENABLE_LOGROTATION = True
              USER = graphite
              MAX_CACHE_SIZE = inf
              MAX_UPDATES_PER_SECOND = 100
              MAX_CREATES_PER_MINUTE = 200
              LINE_RECEIVER_INTERFACE = 0.0.0.0
              LINE_RECEIVER_PORT = 2003
              UDP_RECEIVER_PORT = 2003
              PICKLE_RECEIVER_PORT = 2004
              ENABLE_UDP_LISTENER = True
              CACHE_QUERY_PORT = 7002
              CACHE_WRITE_STRATEGY = sorted
              USE_FLOW_CONTROL = True
              LOG_UPDATES = False
              LOG_CACHE_HITS = False
              WHISPER_AUTOFLUSH = False
              LOCAL_DATA_DIR = /opt/graphite/storage/whisper
              FAKE = fake
            EXP
            expect(chef_run).to create_file('/opt/graphite/conf/carbon.conf')
              .with(content: expected)
          end
        end
      end

      context 'the relay service' do
        let(:service_name) { :relay }

        it_behaves_like 'any service'

        context 'all default properties' do
          include_context description

          it 'renders the expected carbon.conf' do
            expected = <<-EXP.gsub(/^ +/, '')
              # This file is managed by Chef.
              # Any changes to it will be overwritten.
              [relay]
            EXP
            expect(chef_run).to create_file('/opt/graphite/conf/carbon.conf')
              .with(content: expected)
          end
        end

        context 'an overridden config property' do
          include_context description

          it 'renders the expected carbon.conf' do
            expected = <<-EXP.gsub(/^ +/, '')
              # This file is managed by Chef.
              # Any changes to it will be overwritten.
              [relay]
              PANTS = test
            EXP
            expect(chef_run).to create_file('/opt/graphite/conf/carbon.conf')
              .with(content: expected)
          end
        end

        context 'an overridden fake property' do
          include_context description

          it 'renders the expected carbon.conf' do
            expected = <<-EXP.gsub(/^ +/, '')
              # This file is managed by Chef.
              # Any changes to it will be overwritten.
              [relay]
              FAKE = fake
            EXP
            expect(chef_run).to create_file('/opt/graphite/conf/carbon.conf')
              .with(content: expected)
          end
        end
      end

      context 'the aggregator service' do
        let(:service_name) { :aggregator }

        it_behaves_like 'any service'

        context 'all default properties' do
          include_context description

          it 'renders the expected carbon.conf' do
            expected = <<-EXP.gsub(/^ +/, '')
              # This file is managed by Chef.
              # Any changes to it will be overwritten.
              [aggregator]
            EXP
            expect(chef_run).to create_file('/opt/graphite/conf/carbon.conf')
              .with(content: expected)
          end
        end

        context 'an overridden config property' do
          include_context description

          it 'renders the expected carbon.conf' do
            expected = <<-EXP.gsub(/^ +/, '')
              # This file is managed by Chef.
              # Any changes to it will be overwritten.
              [aggregator]
              PANTS = test
            EXP
            expect(chef_run).to create_file('/opt/graphite/conf/carbon.conf')
              .with(content: expected)
          end
        end

        context 'an overridden fake property' do
          include_context description

          it 'renders the expected carbon.conf' do
            expected = <<-EXP.gsub(/^ +/, '')
              # This file is managed by Chef.
              # Any changes to it will be overwritten.
              [aggregator]
              FAKE = fake
            EXP
            expect(chef_run).to create_file('/opt/graphite/conf/carbon.conf')
              .with(content: expected)
          end
        end
      end

      context 'an invalid service' do
        let(:service_name) { :pants }

        it 'raises an error' do
          expect { chef_run }.to raise_error(Chef::Exceptions::ValidationFailed)
        end
      end
    end

    context 'the :remove action' do
      include_context description

      shared_examples_for 'any property set' do
        it 'deletes the carbon.conf' do
          f = path || "#{graphite_path || '/opt/graphite'}/conf/carbon.conf"
          expect(chef_run).to delete_file(f)
        end
      end

      context 'all default properties' do
        include_context description

        it_behaves_like 'any property set'
      end

      %w[graphite_path path].each do |p|
        context "an overridden #{p} property" do
          include_context description

          it_behaves_like 'any property set'
        end
      end
    end
  end

  RSpec.configuration.supported_platforms.each do |os, versions|
    context os.to_s.capitalize do
      let(:platform) { os.to_s }

      versions.each do |ver|
        context ver do
          let(:platform_version) { ver }

          it_behaves_like 'any platform'
        end
      end
    end
  end
end
