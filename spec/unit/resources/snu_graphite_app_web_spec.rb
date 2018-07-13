# frozen_string_literal: true

require_relative '../resources'

describe 'resources::snu_graphite_app_web' do
  include_context 'resources'

  let(:resource) { 'snu_graphite_app_web' }
  %i[
    graphite_path storage_path user group python_runtime version django_version
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
      django_version: django_version
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
    django_version: '4.5.6'
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
          p = 'pytz, pyparsing, python-memcached, uwsgi'
          expect(chef_run).to install_python_package(p)
            .with(virtualenv: graphite_path || '/opt/graphite')
        end

        it 'installs the graphite-web package' do
          expect(chef_run).to install_python_package('graphite-web')
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
        django_version
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
          pkgs = 'graphite-web, pytz, pyparsing, python-memcached, uwsgi, ' \
                 'django-tagging, django'
          expect(chef_run).to remove_python_package(pkgs)
            .with(virtualenv: graphite_path || '/opt/graphite')
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
