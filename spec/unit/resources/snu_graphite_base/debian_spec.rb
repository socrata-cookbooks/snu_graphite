# frozen_string_literal: true

require_relative '../snu_graphite_base'

describe 'resources::snu_graphite_base::debian' do
  include_context 'resources::snu_graphite_base'

  shared_examples_for 'any Debian platform' do
    it_behaves_like 'any platform'

    context 'the :create action' do
      include_context description

      shared_examples_for 'any property set' do
        it 'ensures APT has a fresh cache' do
          expect(chef_run).to periodic_apt_update('default')
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
    next unless %i[ubuntu debian].include?(os)

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
