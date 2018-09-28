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

describe file('/etc/sv/carbon-cache/run') do
  it { should exist }
  its(:owner) { should eq('root') }
  its(:group) { should eq('root') }
  its(:mode) { should cmp('0755') }
  its(:content) do
    expected = <<-EXP.gsub(/^ {6}/, '').strip
      #!/bin/sh

      name="cache"
      user="graphite"
      storage_path="/data/graphite"
      daemon="/opt/graphite/bin/carbon-${type}.py"

      ulimit -H -n 1024
      ulimit -n 1024

      exec 2>&1

      exec chpst \
          -u $user \
          -l $storage_path/${name}.lock -- \
          $daemon \
          --pid /opt/graphite/storage/${name}.pid \
          --debug start
    EXP
    should eq(expected)
  end
end

describe file('/etc/sv/carbon-cache/finish') do
  it { should exist }
  its(:owner) { should eq('root') }
  its(:group) { should eq('root') }
  its(:mode) { should cmp('0755') }
  its(:content) do
    expected = <<-EXP.gsub(/^ {6}/, '')
      #!/bin/sh

      name="cache"
      storage_path="/data/graphite"
      pid="/opt/graphite/storage/${name}.pid"

      if [ -e $pid ]; then
        rm -v $pid
      fi
    EXP
    should eq(expected)
  end
end

describe file('/etc/sv/graphite-web/run') do
  it { should exist }
  its(:owner) { should eq('root') }
  its(:group) { should eq('root') }
  its(:mode) { should cmp('0755') }
  its(:content) do
    expected = <<-EXP.gsub(/^ {6}/, '')
      #!/bin/sh

      ulimit -H -n 1024
      ulimit -n 1024

      exec 2>&1
      exec uwsgi --processes 8 \
      --plugins carbon --carbon 127.0.0.1:2003 \
      --pythonpath /opt/graphite/lib \
      --pythonpath /opt/graphite/webapp/graphite \
      --wsgi-file /opt/graphite/conf/graphite.wsgi.example \
      --uid graphite --gid graphite \
      --chmod-socket=755 \
      --no-orphans --master \
      --procname graphite-web \
      --die-on-term \
      --socket /tmp/uwsgi.sock
    EXP
    should eq(expected)
  end
end

%w[carbon-cache graphite-web].each do |s|
  describe runit_service(s) do
    it { should be_enabled }
    it { should be_running }
  end
end
