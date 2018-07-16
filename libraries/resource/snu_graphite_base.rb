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

class Chef
  class Resource
    # A base resource containing a set of common properties that all the other
    # snu_graphite resources can subclass. This resource class provides nothing
    # and has no actions.
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com
    class SnuGraphiteBase < Resource
      include SnuGraphiteCookbook::Helpers::Base

      # Default to the shared default Graphite path, user, and group.
      property :graphite_path, String, default: DEFAULT_GRAPHITE_PATH
      property :storage_path,
               String,
               default: lazy { |r| ::File.join(r.graphite_path, 'storage') }
      property :user, String, default: DEFAULT_GRAPHITE_USER
      property :group, String, default: DEFAULT_GRAPHITE_GROUP
    end
  end
end
