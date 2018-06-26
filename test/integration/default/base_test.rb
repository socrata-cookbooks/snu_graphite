# frozen_string_literal: true

major_minor = command('python2 --version').stderr.split.last.split('.')[0..1]
                                          .join('.')

describe package("python#{major_minor}") do
  it { should be_installed }
end

describe group('graphite') do
  it { should exist }
  it { should be_system }
end

describe user('graphite') do
  it { should exist }
  it { should be_system }
  its(:groups) { should eq('graphite') }
  its(:home) { should eq('/opt/graphite') }
  its(:shell) { should eq('/bin/false') }
end

describe directory('/opt/graphite') do
  it { should exist }
  its(:owner) { should eq('graphite') }
  its(:group) { should eq('graphite') }
  its(:mode) { should cmp('0755') }
end

describe command('/opt/graphite/bin/python --version') do
  its(:stderr) { should match(/^Python #{major_minor}$/) }
end

%w[storage storage/log storage/whisper storage/rrd].each do |d|
  describe directory(File.join('/opt/graphite', d)) do
    it { should exist }
    its(:owner) { should eq('graphite') }
    its(:group) { should eq('graphite') }
    its(:mode) { should cmp('0755') }
  end
end
