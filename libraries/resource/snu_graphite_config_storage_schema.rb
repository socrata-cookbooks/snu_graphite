# frozen_string_literal: true

#
# Cookbook:: snu_graphite
# Library:: resource/snu_graphite_storage_schema
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
require_relative 'snu_graphite_base'

class Chef
  class Resource
    # A resource for accumulating storage schemas and managing
    # storage-schemas.conf config files. Like other Graphite configs, the
    # storage-schemas.conf is in the .ini format, with every key all
    # capitalized.
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com
    class SnuGraphiteConfigStorageSchema < SnuGraphiteBase
      provides :snu_graphite_config_storage_schema

      property :entry_name, String, name_property: true
      property :path,
               String,
               default: lazy { |r|
                 ::File.join(r.graphite_path, 'conf/storage-schemas.conf')
               }
      property :pattern, String, required: true
      property :retentions, String, required: true

      default_action :create

      #
      # If this resource is being created, save it into the node's run state.
      # This is how we'll implement an accumulator pattern for the various
      # schema entries. The :create action will then render the same config
      # file for each snu_graphite_config_storage_schema resource all together
      # at converge time.
      #
      def after_created
        return unless action.include?(:create)

        run_state_config[entry_name] = { pattern: pattern,
                                         retentions: retentions }
      end

      #
      # Walk through the run state, creating an empty hash at each layer if it
      # doesn't exist yet, then return the layer for this resource's config
      # file.
      #
      def run_state_config
        rs = run_context.node.run_state
        rs[:snu_graphite] ||= {}
        rs[:snu_graphite][:storage_schemas] ||= {}
        rs[:snu_graphite][:storage_schemas][path.to_sym] ||= {}
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
          node.run_state[:snu_graphite][:storage_schemas][new_resource.path.to_sym].sort.to_h
        ).to_s

        file new_resource.path do
          owner new_resource.user
          group new_resource.group
          mode '0644'
          content conf_str
        end
      end

      #
      # If there is nothing in the run state to indicate another resource is
      # going to create this file, it can be deleted. Otherwise, do nothing and
      # let the other resource re-render it.
      #
      action :remove do
        cfg = node.run_state.dig(:snu_graphite,
                                 :storage_schemas,
                                 new_resource.path.to_sym).to_h
        file(new_resource.path) { action :delete } if cfg.empty?
      end
    end
  end
end
