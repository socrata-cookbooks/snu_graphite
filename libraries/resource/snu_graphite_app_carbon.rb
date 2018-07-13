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

require_relative 'snu_graphite_app_base'

class Chef
  class Resource
    # A resource for managing the Carbon app.
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com
    class SnuGraphiteAppCarbon < SnuGraphiteAppBase
      property :twisted_version, String, default: '13.1.0'

      #
      # Build on the base :install action to install Carbon into the
      # virtualenv.
      #
      action :install do
        super()

        python_package 'Twisted' do
          version new_resource.twisted_version
          virtualenv new_resource.graphite_path
        end

        python_package 'carbon' do
          version new_resource.version
          virtualenv new_resource.graphite_path
        end
      end

      # The carbon packages will get uninstalled along with the virtualenv so
      # the :remove action doesn't need to do anything special.
    end
  end
end
