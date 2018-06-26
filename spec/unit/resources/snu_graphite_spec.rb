# frozen_string_literal: true

require_relative '../resources'

describe 'resources::snu_graphite' do
  include_context 'resources'

  let(:resource) { 'snu_graphite' }
  %i[property1 property2].each { |p| let(p) { nil } }
  let(:properties) { { property1: property1, property2: property2 } }
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
    property1: 'somethingelse1',
    property2: 'somethingelse2'
  }.each do |p, v|
    shared_context "an overridden #{p} property" do
      let(p) { v }
    end
  end

  shared_examples_for 'any platform' do
    %w[create remove].each do |act|
      context "the :#{act} action" do
        include_context description

        shared_context 'any property set' do
          it 'converges successfully' do
            expect { chef_run }.to_not raise_error
          end
        end

        %w[property1 property2].each do |p|
          context "an overridden #{p} property" do
            include_context description

            it_behaves_like 'any property set'
          end
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
