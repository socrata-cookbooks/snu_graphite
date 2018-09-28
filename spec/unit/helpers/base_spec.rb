# frozen_string_literal: true

require_relative '../../../libraries/helpers/base'

describe SnuGraphiteCookbook::Helpers::Base do
  it 'sets a default Graphite version' do
    expect(described_class::DEFAULT_GRAPHITE_VERSION).to eq('0.9.12')
  end

  it 'sets a default Graphite path' do
    expect(described_class::DEFAULT_GRAPHITE_PATH).to eq('/opt/graphite')
  end

  it 'sets a default Graphite user' do
    expect(described_class::DEFAULT_GRAPHITE_USER).to eq('graphite')
  end

  it 'sets a default Graphite group' do
    expect(described_class::DEFAULT_GRAPHITE_GROUP).to eq('graphite')
  end
end
