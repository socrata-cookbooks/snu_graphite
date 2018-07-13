# frozen_string_literal: true

require_relative 'snu_graphite_app_base'

shared_context 'resources::snu_graphite_app_web' do
  include_context 'resources::snu_graphite_app_base'

  let(:resource) { 'snu_graphite_app_web' }
  %i[django_version].each { |p| let(p) { nil } }
  let(:properties) do
    {
      graphite_path: graphite_path,
      storage_path: storage_path,
      user: user,
      group: group,
      python_runtime: python_runtime,
      version: version,
      django_version: django_version
    }
  end

  {
    django_version: '4.5.6'
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
        it 'installs the Django package' do
          expect(chef_run).to install_python_package('django')
            .with(version: django_version || '1.5.5',
                  virtualenv: graphite_path || '/opt/graphite')
        end

        it 'installs the django-tagging package' do
          expect(chef_run).to install_python_package('django-tagging')
            .with(version: '0.3.6',
                  virtualenv: graphite_path || '/opt/graphite')
        end

        it 'installs the other Python packages' do
          p = %w[pytz pyparsing python-memcached uwsgi]
          expect(chef_run).to install_python_package(p)
            .with(virtualenv: graphite_path || '/opt/graphite')
        end

        it 'installs the graphite-web package' do
          expect(chef_run).to install_python_package('graphite-web')
            .with(version: django_version || '1.5.5',
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
        django_version
      ].each do |p|
        context "an overridden #{p} property" do
          include_context description

          it_behaves_like 'any property set'
        end
      end
    end
  end
end
