# frozen_string_literal: true

major_minor = command('ls /usr/bin/python2\\.[0-9]*')
              .stdout.split.first.gsub(%r{^/usr/bin/python}, '')

describe package("python#{major_minor}") do
  it { should be_installed }
end

describe group('graphite') do
  it { should_not exist }
end

describe user('graphite') do
  it { should_not exist }
end

describe directory('/opt/graphite') do
  it { should_not exist }
end
