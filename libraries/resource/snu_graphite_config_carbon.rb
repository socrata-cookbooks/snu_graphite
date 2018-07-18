# frozen_string_literal: true

#
# Cookbook:: snu_graphite
# Library:: resource/snu_graphite_config_carbon
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

require_relative '../helpers/config'
require_relative '../helpers/config_carbon'
require_relative 'snu_graphite_base'

class Chef
  class Resource
    # A resource for managing carbon.conf config files. The carbon.conf is
    # in the .ini format, with every key all capitalized.
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com
    class SnuGraphiteConfigCarbon < SnuGraphiteBase
      include SnuGraphiteCookbook::Helpers::ConfigCarbon

      provides :snu_graphite_config_carbon

      property :service_name,
               [String, Symbol],
               name_property: true,
               coerce: proc { |v| v.to_sym },
               equal_to: %i[cache relay aggregator]

      property :path,
               String,
               default: lazy { |r|
                 ::File.join(r.graphite_path, 'conf/carbon.conf')
               }

      property :config,
               Hash,
               default: lazy { |r| r.default_config_for(r.service_name) }

      default_action :create

      #
      # Save the provided config hash into the node's run state. This is how
      # we'll implement an accumulator pattern for the different Carbon
      # services. The :create action will then render the same config file for
      # each snu_graphite_config_carbon resource all together at converge time.
      #
      def after_created
        return unless action.include?(:create)

        run_state_config[service_name] = config
      end

      #
      # Walk through the run state, creating an empty hash at each layer if it
      # doesn't exist yet, then return the layer for this resource's config
      # file.
      #
      def run_state_config
        rs = run_context.node.run_state
        rs[:snu_graphite] ||= {}
        rs[:snu_graphite][:configs] ||= {}
        rs[:snu_graphite][:configs][path.to_sym] ||= {}
      end

      #
      # Allow additional properties to be passed in and merged into the config
      # hash.
      #
      # (see Chef::Resource#method_missing
      #
      def method_missing(method_symbol, *args, &block)
        super
      rescue NoMethodError
        raise if !block.nil? || args.length != 1
        merged = config.merge(method_symbol => args[0])
        config(merged)
      end

      #
      # Nothing special needs to happen here since method_missing only modifies
      # the config hash.
      #
      # (see Object#respond_to_missing?)
      #
      def respond_to_missing?(method_symbol, include_private = false)
        super
      end

      #
      # Generate the config file.
      #
      action :create do
        directory ::File.dirname(new_resource.path) do
          owner new_resource.user
          group new_resource.group
          mode '0755'
          recursive true
        end

        conf_str = SnuGraphiteCookbook::Helpers::Config.new(
          node.run_state[:snu_graphite][:configs][new_resource.path.to_sym]
        ).to_s

        file new_resource.path do
          owner new_resource.user
          group new_resource.group
          mode '0644'
          content conf_str
          sensitive true
        end
      end

      #
      # If there is nothing in the run state to indicate another resource is
      # going to create this file, it can be deleted. Otherwise, do nothing and
      # let the other resource re-render it.
      #
      action :remove do
        cfg = node.run_state.dig(:snu_graphite,
                                 :configs,
                                 new_resource.path.to_sym).to_h
        file(new_resource.path) { action :delete } if cfg.empty?
      end
    end
  end
end
