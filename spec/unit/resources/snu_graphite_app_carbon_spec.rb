# frozen_string_literal: true

require_relative '../resources'

describe 'resources::snu_graphite_app_carbon' do
  include_context 'resources'

  let(:resource) { 'snu_graphite_app_carbon' }

  %i[
    graphite_path storage_path user group python_runtime version twisted_version
  ].each do |p|
    let(p) { nil }
  end
  let(:properties) do
    {
      graphite_path: graphite_path,
      storage_path: storage_path,
      user: user,
      group: group,
      python_runtime: python_runtime,
      version: version,
      twisted_version: twisted_version
    }
  end
  let(:name) { 'default' }

  shared_context 'the :install action' do
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
    python_runtime: '3',
    version: '1.2.3',
    twisted_version: '4.5.6'
  }.each do |p, v|
    shared_context "an overridden #{p} property" do
      let(p) { v }
    end
  end

  shared_examples_for 'any platform' do
    context 'the :install action' do
      include_context description

      shared_examples_for 'any property set' do
        it 'installs the app base' do
          str = storage_path || "#{graphite_path || '/opt/graphite'}/storage"
          expect(chef_run).to install_snu_graphite_app_base(name)
            .with(graphite_path: graphite_path || '/opt/graphite',
                  storage_path: str,
                  user: user || 'graphite',
                  group: group || 'graphite',
                  python_runtime: python_runtime || '2',
                  version: version || '0.9.12')
        end

        it 'installs the Twisted package' do
          expect(chef_run).to install_python_package('Twisted')
            .with(version: twisted_version || '13.1.0',
                  virtualenv: graphite_path || '/opt/graphite')
        end

        it 'installs the Carbon package' do
          expect(chef_run).to install_python_package('carbon')
            .with(version: version || '0.9.12',
                  virtualenv: graphite_path || '/opt/graphite')
        end
      end

      context 'all default properties' do
        include_context description

        it_behaves_like 'any property set'
      end

      %w[
        graphite_path
        storage_path
        user
        group
        python_runtime
        version
        twisted_version
      ].each do |p|
        context "an overridden #{p} property" do
          include_context description

          it_behaves_like 'any property set'
        end
      end
    end

    context 'the :remove action' do
      include_context description

      shared_examples_for 'any property set' do
        it 'removes the Python packages' do
          expect(chef_run).to remove_python_package('carbon, Twisted')
            .with(virtualenv: graphite_path || '/opt/graphite')
        end
      end

      context 'all default properties' do
        include_context description

        it_behaves_like 'any property set'
      end

      %w[
        graphite_path
        storage_path
        user
        group
        python_runtime
        version
        twisted_version
      ].each do |p|
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
