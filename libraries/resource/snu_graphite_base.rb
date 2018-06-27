# frozen_string_literal: true

#
# Cookbook:: snu_graphite
# Library:: resource/snu_graphite_base
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

require 'chef/resource'
require_relative '../helpers'

class Chef
  class Resource
    # A base resource for managing the essentials shared by other graphite
    # resources
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com
    class SnuGraphiteBase < Resource
      # Default to the shared default Graphite path, user, and group.
      property :graphite_path,
               String,
               default: SnuGraphiteCookbook::Helpers::DEFAULT_GRAPHITE_PATH
      property :storage_path,
               String,
               default: lazy { |r| ::File.join(r.graphite_path, 'storage') }
      property :user,
               String,
               default: SnuGraphiteCookbook::Helpers::DEFAULT_GRAPHITE_USER
      property :group,
               String,
               default: SnuGraphiteCookbook::Helpers::DEFAULT_GRAPHITE_GROUP
      property :python_runtime, String, default: '2'

      default_action :create

      #
      # Do the base work that other graphite resources require.
      #
      action :create do
        declare_resource(:python_runtime, new_resource.python_runtime)

        declare_resource(:group, new_resource.group) { system true }

        declare_resource(:user, new_resource.user) do
          system true
          group new_resource.group
          # TODO: Or '/var/lib/graphite'?
          manage_home true
          home new_resource.graphite_path
          shell '/bin/false'
        end

        python_virtualenv new_resource.graphite_path do
          python new_resource.python_runtime
          user new_resource.user
          group new_resource.group
        end

        %w[log whisper rrd].each do |d|
          directory ::File.join(new_resource.storage_path, d) do
            owner new_resource.user
            group new_resource.group
            mode '0755'
            recursive true
          end
        end
      end

      #
      # Delete the graphite group and user. We can't assume graphite is the
      # only thing on the node using Python, so the runtime gets left behind.
      #
      action :remove do
        directory new_resource.storage_path do
          recursive true
          action :delete
        end

        python_virtualenv(new_resource.graphite_path) { action :delete }

        declare_resource(:user, new_resource.user) { action :remove }
        declare_resource(:group, new_resource.group) { action :remove }
      end
    end
  end
end
