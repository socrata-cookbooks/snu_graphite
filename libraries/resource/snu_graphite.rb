# frozen_string_literal: true

#
# Cookbook:: snu_graphite
# Library:: resource/snu_graphite
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

class Chef
  class Resource
    # TODO: Add a brief resource description.
    #
    # @author Jonathan Hartman <j@hartman.io>
    class SnuGraphite < Resource
      provides :snu_graphite

      property :property1, String, default: 'value1'
      property :property2, String, default: 'value2'

      default_action :create

      #
      # TODO: Describe the action's behavior.
      #
      action :create do
        Chef::Log.warn("Property1 is #{new_resource.property1}")
        Chef::Log.warn("Property2 is #{new_resource.property2}")
      end

      #
      # TODO: Describe the action's behavior.
      #
      action :remove do
        Chef::Log.warn("Property1 is #{new_resource.property1}")
        Chef::Log.warn("Property2 is #{new_resource.property2}")
      end
    end
  end
end
