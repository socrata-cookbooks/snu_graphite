# frozen_string_literal: true

require_relative 'snu_graphite_app_base'

shared_context 'resources::snu_graphite_app_carbon' do
  include_context 'resources::snu_graphite_app_base'

  let(:resource) { 'snu_graphite_app_carbon' }
  %i[twisted_version].each { |p| let(p) { nil } }
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

  {
    twisted_version: '4.5.6'
  }.each do |p, v|
    shared_context "an overridden #{p} property" do
      let(p) { v }
    end
  end

  shared_examples_for 'any platform' do
    it_behaves_like 'any Graphite app'

    context 'the :install action' do
      include_context description

      shared_examples_for 'any property set' do
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
end
