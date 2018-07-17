# frozen_string_literal: true

describe file('/opt/graphite/conf/carbon.conf') do
  it { should exist }
  its(:owner) { should eq('graphite') }
  its(:group) { should eq('graphite') }
  its(:mode) { should cmp('0644') }
  its(:content) do
    expected = <<-EXP.gsub(/^ +/, '').strip
      # This file is managed by Chef.
      # Any changes to it will be overwritten.
      [cache]
      ENABLE_LOGROTATION = True
      USER = graphite
      MAX_CACHE_SIZE = inf
      MAX_UPDATES_PER_SECOND = 100
      MAX_CREATES_PER_MINUTE = 200
      LINE_RECEIVER_INTERFACE = 0.0.0.0
      LINE_RECEIVER_PORT = 2003
      UDP_RECEIVER_PORT = 2003
      PICKLE_RECEIVER_PORT = 2004
      ENABLE_UDP_LISTENER = True
      CACHE_QUERY_PORT = 7002
      CACHE_WRITE_STRATEGY = sorted
      USE_FLOW_CONTROL = True
      LOG_UPDATES = False
      LOG_CACHE_HITS = False
      WHISPER_AUTOFLUSH = False
      LOCAL_DATA_DIR = /opt/graphite/storage/whisper/
    EXP
    should eq(expected)
  end
end