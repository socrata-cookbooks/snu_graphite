# frozen_string_literal: true

#
# Cookbook:: snu_graphite
# Library:: resource/snu_graphite_app_carbon
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
require_relative 'snu_graphite_app_base'

class Chef
  class Resource
    # A resource for managing the Carbon app.
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com
    class SnuGraphiteAppCarbon < Resource
      provides :snu_graphite_app_carbon

      property :twisted_version, String, default: '13.1.0'

      # Inherit all the base resource's properties as well.
      Chef::Resource::SnuGraphiteAppBase.state_properties.each do |prop|
        property prop.name, prop.options
      end

      default_action :install

      #
      # Build on the base :install action to install Carbon into the
      # virtualenv.
      #
      action :install do
        snu_graphite_app_base new_resource.name do
          Chef::Resource::SnuGraphiteAppBase
            .state_properties.map(&:name).each do |prop|
            unless new_resource.send(prop).nil?
              send(prop, new_resource.send(prop))
            end
          end
          action :install
        end

        python_package 'Twisted' do
          version new_resource.twisted_version
          virtualenv new_resource.graphite_path
        end

        python_package 'carbon' do
          version new_resource.version
          virtualenv new_resource.graphite_path
        end
      end

      #
      # Uninstall the carbon and Twisted packages. Any other cleanup (e.g.
      # users, graphite dirs, etc.) should be done with a
      # `snu_graphite_app_base('default') { action :remove }` lest we risk
      # unintentionally installing another app that happens to be using the
      # same virtualenv.
      #
      action :remove do
        python_package %w[carbon Twisted] do
          virtualenv new_resource.graphite_path
          action :remove
        end
      end
    end
  end
end
