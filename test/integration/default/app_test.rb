# frozen_string_literal: true

{
  'Twisted' => '13.1.0',
  'carbon' => '0.9.12'
}.each do |pkg, ver|
  describe pip(pkg, '/opt/graphite/bin/pip') do
    it { should be_installed }
    its(:version) { should eq(ver) }
  end
end
