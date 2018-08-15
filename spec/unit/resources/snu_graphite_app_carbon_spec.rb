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

  let(:carbon_installed) { nil }

  before do
    pip = [
      { 'name' => 'thing1', 'version' => '1.2.3' },
      { 'name' => 'thing2', 'version' => '4.5.6' }
    ]
    if carbon_installed
      pip << { 'name' => 'carbon', 'version' => carbon_installed }
    end
    allow_any_instance_of(Chef::Mixin::ShellOut).to receive(:shell_out!)
      .and_return(double(stdout: pip.to_json))
  end

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
                  virtualenv: graphite_path || '/opt/graphite',
                  user: user || 'graphite',
                  group: group || 'graphite')
        end

        it 'installs the whisper and txAMQP packages' do
          expect(chef_run).to install_python_package('whisper, txAMQP')
            .with(virtualenv: graphite_path || '/opt/graphite',
                  user: user || 'graphite',
                  group: group || 'graphite')
        end

        it 'executes the Carbon installation' do
          expect(chef_run).to run_python_execute('Install Carbon')
            .with(command: '-m pip.__main__ install --no-binary=:all: ' \
                           '--install-option=' \
                           "'--prefix=#{graphite_path || '/opt/graphite'}' " \
                           '--install-option=' \
                           "'--install-lib=" \
                           "#{graphite_path || '/opt/graphite'}/lib' " \
                           "carbon==#{version || '0.9.12'}",
                  virtualenv: graphite_path || '/opt/graphite',
                  user: user || 'graphite',
                  group: group || 'graphite',
                  environment: {
                    'PYTHONPATH' => "#{graphite_path || '/opt/graphite'}/lib"
                  })
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

      context 'the desired version of Carbon already installed' do
        let(:carbon_installed) { '0.9.12' }

        it 'does not execute the Carbon installation' do
          expect(chef_run).to_not run_python_execute('Install Carbon')
        end
      end

      context 'another version of Carbon already installed' do
        let(:carbon_installed) { '1.2.3' }

        it 'executes the Carbon installation' do
          expect(chef_run).to run_python_execute('Install Carbon')
            .with(command: '-m pip.__main__ install --no-binary=:all: ' \
                           "--install-option='--prefix=/opt/graphite' " \
                           '--install-option=' \
                           "'--install-lib=/opt/graphite/lib' " \
                           'carbon==0.9.12',
                  virtualenv: '/opt/graphite',
                  user: 'graphite',
                  group: 'graphite',
                  environment: { 'PYTHONPATH' => '/opt/graphite/lib' })
        end
      end
    end

    context 'the :remove action' do
      include_context description

      shared_examples_for 'any property set' do
        it 'does not execute the Carbon uninstallation' do
          expect(chef_run).to_not run_python_execute('Uninstall Carbon')
        end

        it 'removes the txAMQP, whisper, and Twisted packages' do
          expect(chef_run).to remove_python_package('txAMQP, whisper, Twisted')
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

      context 'the desired version of Carbon already installed' do
        let(:carbon_installed) { '0.9.12' }

        it 'executes the Carbon uninstallation' do
          expect(chef_run).to run_python_execute('Uninstall Carbon')
            .with(command: '-m pip.__main__ uninstall carbon',
                  virtualenv: '/opt/graphite',
                  environment: { 'PYTHONPATH' => '/opt/graphite/lib' })
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
