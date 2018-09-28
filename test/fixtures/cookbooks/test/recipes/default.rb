# frozen_string_literal: true

include_recipe 'snu_graphite'

snu_graphite_config_storage_schema '500_core_60s_6days_15min_year' do
  pattern '^core\\.'
  retentions '60s:1d,15m:7d,1h:365d'
end

snu_graphite_config_storage_schema '500_metrics_default' do
  pattern '^metrics\\.'
  retentions '60s:1d,15m:7d,1h:365d'
end
