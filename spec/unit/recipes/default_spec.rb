# frozen_string_literal: true

require_relative '../../spec_helper'

describe 'snu_graphite::default' do
  let(:platform) { nil }
  let(:platform_version) { nil }
  let(:runner) do
    ChefSpec::SoloRunner.new(platform: platform, version: platform_version)
  end
  let(:chef_run) { runner.converge(described_recipe) }

  shared_examples_for 'any platform' do
    it 'creates the snu_graphite_base' do
      expect(chef_run).to create_snu_graphite_base('default')
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
