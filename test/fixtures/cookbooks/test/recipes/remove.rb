# frozen_string_literal: true

include_recipe 'snu_graphite'

snu_graphite_carbon_app 'remove' do
  action :remove
end

snu_graphite_base 'remove' do
  action :remove
end
