# frozen_string_literal: true

describe file('/opt/graphite/conf/carbon.conf') do
  it { should_not exist }
end
