# frozen_string_literal: true

#
# Cookbook:: snu_graphite
# Library:: helpers/config_carbon
#
# Copyright:: 2018, Socrata, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'iniparse'

module SnuGraphiteCookbook
  module Helpers
    # Some default settings and helpers for dealing with Graphite's carbon.conf
    # files.
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com>
    module ConfigCarbon
      DEFAULT_CACHE_CONFIG ||= {
        enable_logrotation: true,
        user: '%<user>s',
        max_cache_size: 'inf',
        max_updates_per_second: 100,
        max_creates_per_minute: 200,
        line_receiver_interface: '0.0.0.0',
        line_receiver_port: 2003,
        udp_receiver_port: 2003,
        pickle_receiver_port: 2004,
        enable_udp_listener: true,
        cache_query_port: 7002,
        cache_write_strategy: 'sorted',
        use_flow_control: true,
        log_updates: false,
        log_cache_hits: false,
        whisper_autoflush: false,
        local_data_dir: '%<storage_path>s/whisper'
      }.freeze
      DEFAULT_RELAY_CONFIG ||= {}.freeze
      DEFAULT_AGGREGATOR_CONFIG ||= {}.freeze

      #
      # Return the default config hash for a service, inserting properties from
      # the new resource where string interpolation is required.
      #
      # @param service [Symbol, String] cache, relay, or aggregator
      # @return [Hash] the config cache, with snake-cased symbol keys
      #
      def default_config_for(service)
        ConfigCarbon.const_get("DEFAULT_#{service.upcase}_CONFIG")
                    .each_with_object({}) do |(k, v), hsh|
          hsh[k] = if v.is_a?(String)
                     format(v, user: user, storage_path: storage_path)
                   else
                     v
                   end
        end
      end
    end
  end
end
