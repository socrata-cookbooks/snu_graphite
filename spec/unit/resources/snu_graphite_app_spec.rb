# frozen_string_literal: true

require_relative '../resources'

describe 'resources::snu_graphite_app' do
  include_context 'resources'

  let(:resource) { 'snu_graphite_app' }
  %i[app_name options graphite_path user].each { |p| let(p) { nil } }
  let(:properties) do
    {
      app_name: app_name,
      options: options,
      graphite_path: graphite_path,
      user: user
    }
  end
  let(:name) { %w[carbon web] }

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
    app_name: 'web',
    options: { group: 'you' },
    graphite_path: '/tmp/graph',
    user: 'me'
  }.each do |p, v|
    shared_context "an overridden #{p} property" do
      let(p) { v }
    end
  end

  shared_examples_for 'any platform' do
    context 'the :install action' do
      include_context description

      shared_examples_for 'any property set' do
        it 'installs the carbon app when asked' do
          unless !app_name.nil? && !Array(app_name).include?('carbon')
            props = options.to_h.merge(
              graphite_path: graphite_path || '/opt/graphite',
              user: user || 'graphite'
            )
            expect(chef_run).to install_snu_graphite_app_carbon('default')
              .with(props)
          end
        end

        it 'installs the web app when asked' do
          unless !app_name.nil? && !Array(app_name).include?('web')
            props = options.to_h.merge(
              graphite_path: graphite_path || '/opt/graphite',
              user: user || 'graphite'
            )
            expect(chef_run).to install_snu_graphite_app_web('default')
              .with(props)
          end
        end
      end

      context 'all default properties' do
        include_context description

        it_behaves_like 'any property set'
      end

      %w[app_name options graphite_path user].each do |p|
        context "an overridden #{p} property" do
          include_context description

          it_behaves_like 'any property set'
        end
      end
    end

    context 'the :remove action' do
      include_context description

      shared_examples_for 'any property set' do
        it 'removes the carbon app when asked' do
          unless !app_name.nil? && !Array(app_name).include?('carbon')
            props = options.to_h.merge(
              graphite_path: graphite_path || '/opt/graphite',
              user: user || 'graphite'
            )
            expect(chef_run).to remove_snu_graphite_app_carbon('default')
              .with(props)
          end
        end

        it 'removes the web app when asked' do
          unless !app_name.nil? && !Array(app_name).include?('web')
            props = options.to_h.merge(
              graphite_path: graphite_path || '/opt/graphite',
              user: user || 'graphite'
            )
            expect(chef_run).to remove_snu_graphite_app_web('default')
              .with(props)
          end
        end
      end

      context 'all default properties' do
        include_context description

        it_behaves_like 'any property set'
      end

      %w[app_name options graphite_path user].each do |p|
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
