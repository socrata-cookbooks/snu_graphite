# frozen_string_literal: true

require_relative '../resources'

describe 'resources::snu_graphite_base' do
  include_context 'resources'

  let(:resource) { 'snu_graphite_base' }
  %i[graphite_path storage_path user group python_runtime].each do |p|
    let(p) { nil }
  end
  let(:properties) do
    {
      graphite_path: graphite_path,
      storage_path: storage_path,
      user: user,
      group: group,
      python_runtime: python_runtime
    }
  end
  let(:name) { 'default' }

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
    python_runtime: '3'
  }.each do |p, v|
    shared_context "an overridden #{p} property" do
      let(p) { v }
    end
  end

  shared_examples_for 'any platform' do
    context 'the :create action' do
      include_context description

      shared_examples_for 'any property set' do
        it 'installs the python runtime' do
          expect(chef_run).to install_python_runtime(python_runtime || '2')
        end

        it 'creates the group' do
          expect(chef_run).to create_group(group || 'graphite')
            .with(system: true)
        end

        it 'creates the user' do
          expect(chef_run).to create_user(user || 'graphite')
            .with(system: true,
                  group: group || 'graphite',
                  home: graphite_path || '/opt/graphite',
                  shell: '/bin/false')
        end

        it 'creates the virtualenv' do
          v = graphite_path || '/opt/graphite'
          expect(chef_run).to create_python_virtualenv(v)
            .with(python: python_runtime || '2',
                  user: user || 'graphite',
                  group: group || 'graphite')
        end

        %w[log whisper rrd].each do |dir|
          it "creates the #{dir} directory" do
            d = File.join(
              storage_path || "#{graphite_path || '/opt/graphite'}/storage",
              dir
            )
            expect(chef_run).to create_directory(d)
              .with(owner: user || 'graphite',
                    group: group || 'graphite',
                    mode: '0755',
                    recursive: true)
          end
        end
      end

      %w[graphite_path storage_path user group python_runtime].each do |p|
        context "an overridden #{p} property" do
          include_context description

          it_behaves_like 'any property set'
        end
      end
    end

    context 'the :remove action' do
      include_context description

      shared_examples_for 'any property set' do
        it 'deletes the storage directory' do
          d = storage_path || "#{graphite_path || '/opt/graphite'}/storage"
          expect(chef_run).to delete_directory(d).with(recursive: true)
        end

        it 'deletes the virtualenv' do
          d = graphite_path || '/opt/graphite'
          expect(chef_run).to delete_python_virtualenv(d)
        end

        it 'removes the user' do
          expect(chef_run).to remove_user(user || 'graphite')
        end

        it 'removes the group' do
          expect(chef_run).to remove_group(group || 'graphite')
        end
      end

      %w[graphite_path storage_path user group python_runtime].each do |p|
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