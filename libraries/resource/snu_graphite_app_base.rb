# frozen_string_literal: true

#
# Cookbook:: snu_graphite
# Library:: resource/snu_graphite_app_base
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

require 'chef/dsl/declare_resource'
require_relative 'snu_graphite_base'

class Chef
  class Resource
    # A base resource for managing the Graphite apps that the carbon and web
    # resources can wrap for their shared functionality.
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com
    class SnuGraphiteAppBase < SnuGraphiteBase
      include Chef::DSL::DeclareResource

      # Add properties for the Graphite version and Python runtime to use.
      property :version, String, default: DEFAULT_GRAPHITE_VERSION
      property :python_runtime, String, default: '2'

      default_action :install

      #
      # A python_virtualenv resource needs to exist at compile time so that any
      # python_package resources can find it. It doesn't need to be set up,
      # however, so that piece can still occur in the :install action below.
      #
      def after_created
        pyr = declare_resource(:python_runtime, python_runtime)
        pyr.action(:nothing)
        virt = declare_resource(:python_virtualenv, graphite_path)
        virt.python(python_runtime)
        virt.user(user)
        virt.group(group)
        virt.action(:nothing)
      end

      #
      # Do the install work that's common to both the carbon and web app
      # resources:
      #
      # - Create the graphite group and user
      # - Install the Python runtime
      # - Set up a Python virtualenv
      #
      action :install do
        declare_resource(:group, new_resource.group) { system true }

        declare_resource(:user, new_resource.user) do
          system true
          group new_resource.group
          # TODO: Or '/var/lib/graphite'?
          manage_home true
          home new_resource.graphite_path
          shell '/bin/false'
        end

        declare_resource(:python_runtime, new_resource.python_runtime)
        python_virtualenv new_resource.graphite_path do
          python new_resource.python_runtime
          user new_resource.user
          group new_resource.group
        end

        directory new_resource.storage_path do
          owner new_resource.user
          group new_resource.group
          mode '0755'
          recursive true
        end

        create_storage_subdirs!
      end

      #
      # Do the remove work that's common to both the carbon and web app
      # resources:
      #
      # - Delete the storage directory
      # - Delete the python virtualenv
      # - Remove the graphite user and group
      #
      # Note the destructiveness of this action and potential unintended
      # consequences if the carbon and web app are deployed to the same
      # directories.
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

      action_class do
        def create_storage_subdirs!
          %w[log whisper rrd].each do |d|
            directory ::File.join(new_resource.storage_path, d) do
              owner new_resource.user
              group new_resource.group
              mode '0755'
            end
          end
        end
      end
    end
  end
end
