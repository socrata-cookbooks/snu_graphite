# frozen_string_literal: true

describe directory('/opt/graphite/storage/log/webapp') do
  it { should exist }
  its(:owner) { should eq('graphite') }
  its(:group) { should eq('graphite') }
  its(:mode) { should cmp('0755') }
end

%w[access error exception info].each do |f|
  describe file("/opt/graphite/storage/log/webapp/#{f}.log") do
    it { should exist }
    its(:owner) { should eq('graphite') }
    its(:group) { should eq('graphite') }
    its(:mode) { should cmp('0644') }
  end
end

%w[carbon-cache graphite-web].each do |s|
  describe runit_service(s) do
    it { should be_enabled }
    it { should be_running }
  end
end
