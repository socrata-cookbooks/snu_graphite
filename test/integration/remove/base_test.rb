# frozen_string_literal: true

major_minor = command('python2 --version').stderr.split.last.split('.')[0..1]
                                          .join('.')

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
