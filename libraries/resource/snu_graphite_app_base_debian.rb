# frozen_string_literal: true

#
# Cookbook:: snu_graphite
# Library:: resource/snu_graphite_app_base_debian
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
    # A resource for managing Graphite apps on Debian platforms.
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com
    class SnuGraphiteAppBaseDebian < SnuGraphiteAppBase
      provides :snu_graphite_app_base, platform_family: 'debian'

      #
      # Ensure APT has a fresh cache before doing anything else.
      #
      action :install do
        apt_update 'default'
        super()
      end
    end
  end
end
