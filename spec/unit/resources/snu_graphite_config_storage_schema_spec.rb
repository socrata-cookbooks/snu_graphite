# frozen_string_literal: true

require_relative '../resources'

describe 'resources::snu_graphite_config_storage_schema' do
  include_context 'resources'

  let(:resource) { 'snu_graphite_config_storage_schema' }

  %i[entry_name graphite_path user group path pattern retentions].each do |p|
    let(p) { nil }
  end
  let(:properties) do
    {
      entry_name: entry_name,
      graphite_path: graphite_path,
      user: user,
      group: group,
      path: path,
      pattern: pattern,
      retentions: retentions
    }
  end
  let(:name) { '500_carbon' }

  shared_context 'the :create action' do
    let(:pattern) { '^carbon\\.' }
    let(:retentions) { '60s:90d' }
  end

  %i[remove].each do |a|
    shared_context "the :#{a} action" do
      let(:action) { a }
    end
  end

  shared_context 'all default properties' do
  end

  {
    entry_name: 'something_else',
    graphite_path: '/tmp/graph',
    user: 'fauxhai',
    group: 'fauxhai',
    path: '/tmp/schemas.conf'
  }.each do |p, v|
    shared_context "an overridden #{p} property" do
      let(p) { v }
    end
  end

  shared_examples_for 'any platform' do
    context 'the :create action' do
      include_context description

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

        it 'creates the storage-schemas.conf' do
          f = path || "#{graphite_path || '/opt/graphite'}/conf/" \
                      'storage-schemas.conf'
          expected = <<-EXP.gsub(/^ +/, '')
            # This file is managed by Chef.
            # Any changes to it will be overwritten.
            [#{entry_name || name}]
            PATTERN = #{pattern}
            RETENTIONS = #{retentions}
          EXP
          expect(chef_run).to create_file(f)
            .with(owner: user || 'graphite',
                  group: group || 'graphite',
                  mode: '0644',
                  content: expected)
        end
      end

      context 'all default properties' do
        include_context description

        it_behaves_like 'any property set'
      end

      %w[entry_name graphite_path user group path].each do |p|
        context "an overridden #{p} property" do
          include_context description

          it_behaves_like 'any property set'
        end
      end
    end

    context 'the :remove action' do
      include_context description

      shared_examples_for 'any property set' do
        it 'deletes the storage-schemas.conf' do
          f = path || "#{graphite_path || '/opt/graphite'}/conf/" \
                      'storage-schemas.conf'
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
