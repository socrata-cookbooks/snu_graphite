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

      # Some helper methods for generating carbon.conf files. Chef is packaged
      # with the iniparse gem, which gets us most of the way there. The file is
      # essentially an ini document that only ever grows one group deep, but
      # with a little bit of a difference:
      #
      #   - All keys are fully capitalized
      #   - All bolean values have the first letter capitalized
      #
      # @author Jonathan Hartman <jonathan.hartman@socrata.com>
      class Config
        #
        # Initialize a new object from a config hash.
        #
        # @param hsh [Hash] a config hash
        # @return [SnuGraphiteCookbook::Helpers::ConfigCarbon::Config] object
        #
        def initialize(hsh = {})
          @config = hsh || {}
        end

        #
        # Return the full string for a carbon.conf file.
        #
        # @return [String] the content of a carbon.conf
        #
        def to_s
          [header, body].join("\n")
        end
        alias inspect to_s

        private

        attr_accessor :config

        #
        # Return the body portion of a carbon.conf.
        #
        # @return [String] the .ini content, stringified
        #
        def body
          to_ini.to_s
        end

        #
        # Convert the config hash into an .ini document object.
        #
        # @return [IniParse::Document] the .ini document
        #
        def to_ini
          IniParse.gen do |doc|
            config.each do |section, data|
              next if data.nil?
              doc.section(section) do |section|
                data.each do |k, v|
                  section.option(key_for(k), value_for(v))
                end
              end
            end
          end
        end

        #
        # Return the header text for a carbon.conf file.
        #
        # @return [String] header comment text
        #
        def header
          <<-CONTENT.gsub(/^ +/, '').strip
            # This file is managed by Chef.
            # Any changes to it will be overwritten.
          CONTENT
        end

        #
        # Translate a hash value into a string suitable for a carbon.conf
        # using the following rules:
        #
        #   * String => String
        #   * Integer => String
        #   * Boolean => String, capitalized
        #
        # @param val [String, Integer, TrueClass, FalseClass] a value
        # @return [String] that value, ready for a carbon.conf
        #
        def value_for(val)
          case val
          when TrueClass
            'True'
          when FalseClass
            'False'
          else
            val.to_s
          end
        end

        #
        # Translate a symbolized, snake-cased key from a Ruby hash into a
        # snake-cased, all-caps string for a carbon.conf
        #
        # @param key [Symbol] a symbolized, snake-cased key from a Ruby hash
        # @return [String] that key, stringified and upcased
        def key_for(key)
          key.to_s.upcase
        end
      end
    end
  end
end
