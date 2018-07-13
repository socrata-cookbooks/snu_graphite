# frozen_string_literal: true

major_minor = command('ls /usr/bin/python2\\.[0-9]*')
              .stdout.split.first.gsub(%r{^/usr/bin/python}, '')

describe package("python#{major_minor}") do
  it { should be_installed }
end

describe group('graphite') do
  it { should exist }
  its(:gid) { should cmp < 1000 }
end

describe user('graphite') do
  it { should exist }
  its(:uid) { should cmp < 1000 }
  its(:groups) { should eq(%w[graphite]) }
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
  its(:stderr) { should match(/^Python #{major_minor}\.[0-9]+$/) }
end

%w[storage storage/log storage/whisper storage/rrd].each do |d|
  describe directory(File.join('/opt/graphite', d)) do
    it { should exist }
    its(:owner) { should eq('graphite') }
    its(:group) { should eq('graphite') }
    its(:mode) { should cmp('0755') }
  end
end

{
  'Twisted' => '13.1.0',
  'carbon' => '0.9.12',
  'Django' => '1.5.5',
  'django-tagging' => '0.3.6',
  'pytz' => nil,
  'pyparsing' => nil,
  'python-memcached' => nil,
  'uWSGI' => nil
}.each do |pkg, ver|
  describe pip(pkg, '/opt/graphite/bin/pip') do
    it { should be_installed }
    its(:version) { should eq(ver) } unless ver.nil?
  end
end
