# frozen_string_literal: true

#
# Cookbook:: snu_graphite
# Library:: resource/snu_graphite_carbon_app
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
    # A resource for managing the Carbon app.
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com
    class SnuGraphiteCarbonApp < Resource
      provides :snu_graphite_carbon_app

      property :graphite_path,
               String,
               default: SnuGraphiteCookbook::Helpers::DEFAULT_GRAPHITE_PATH
      property :version,
               String,
               default: SnuGraphiteCookbook::Helpers::DEFAULT_GRAPHITE_VERSION
      property :twisted_version, String, default: '13.1.0'

      default_action :install

      #
      # Install the Python packages for Carbon into the virtualenv.
      #
      action :install do
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
      # Uninstall the Carbon Python packages.
      action :remove do
        python_package %w[carbon Twisted] do
          virtualenv new_resource.graphite_path
          action :remove
        end
      end
    end
  end
end
