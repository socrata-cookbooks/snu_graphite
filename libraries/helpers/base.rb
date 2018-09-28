# frozen_string_literal: true

#
# Cookbook:: snu_graphite
# Library:: helpers/base
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

module SnuGraphiteCookbook
  module Helpers
    # Some shared helper constants common to all of our graphite resources.
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com>
    module Base
      DEFAULT_GRAPHITE_VERSION ||= '0.9.12'.freeze
      DEFAULT_GRAPHITE_PATH ||= '/opt/graphite'.freeze
      DEFAULT_GRAPHITE_USER ||= 'graphite'.freeze
      DEFAULT_GRAPHITE_GROUP ||= 'graphite'.freeze
    end
  end
end
