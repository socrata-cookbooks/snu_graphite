# frozen_string_literal: true

#
# Cookbook:: snu_graphite
# Library:: resource/snu_graphite_app
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

require 'chef/exceptions'
require 'chef/resource'

class Chef
  class Resource
    # A resource for managing Graphite apps.
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com
    class SnuGraphiteApp < Resource
      provides :snu_graphite_app

      property :app_name,
               [String, Array],
               identity: true,
               callbacks: {
                 'Valid app names are: carbon, web' => \
                   proc { |v| (Array(v) - %w[carbon web]).empty? }
               }

      property :options,
               Hash,
               default: {}

      default_action :install

      #
      # Borrow the name capture from Chef::Resource::Package for array app_name
      # support.
      #
      # (see Chef::Resource#initialize)
      #
      def initialize(name, *args)
        app_name(name)
        super
      end

      #
      # Allow additional properties to be passed in and merged into the options
      # hash.
      #
      # (see Chef::Resource#method_missing
      #
      def method_missing(method_symbol, *args, &block)
        super
      rescue NoMethodError
        raise if !block.nil? || args.length != 1
        merged = options.merge(method_symbol => args[0])
        options(merged)
      end

      #
      # Nothing special needs to happen here since method_missing only modifies
      # the options hash.
      #
      # (see Object#respond_to_missing?)
      #
      def respond_to_missing?(method_symbol, include_private = false)
        super
      end

      #
      # For each specified app, pass on the action and options to it.
      #
      %i[install remove].each do |act|
        action act do
          Array(new_resource.app_name).each do |app|
            send("snu_graphite_app_#{app}", 'default') do
              new_resource.options.each do |k, v|
                send(k, v) unless v.nil?
              end
            end
          end
        end
      end
    end
  end
end
