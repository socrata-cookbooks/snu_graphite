# frozen_string_literal: true

#
# Cookbook:: snu_graphite
# Library:: resource/snu_graphite_service
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
    # A resource for managing Graphite services.
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com
    class SnuGraphiteService < Resource
      provides :snu_graphite_service

      property :service_name,
               [String, Array],
               identity: true,
               callbacks: {
                 'Valid app names are: cache, relay, aggregator, web' => \
                   proc { |v| (Array(v) - %w[cache relay aggregator web])
                              .empty? }
               }

      property :options,
               Hash,
               default: {}

      default_action %i[create enable start]

      #
      # Borrow the name capture from Chef::Resource::Package for array service_name
      # support.
      #
      # (see Chef::Resource#initialize)
      #
      def initialize(name, *args)
        service_name(name)
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
      # Every action should be passed on to one or more underlying
      # snu_graphite_service_* resources.
      #
      # The runit_service resource only declares its allowed actions at the
      # instance level, so we have to declare a fake one to get that info.
      #
      Chef::Resource::RunitService.new('fake', nil).allowed_actions
                                                   .each do |act|
        action act do
          with_run_context new_resource.run_context do
            Array(new_resource.service_name).each do |svc|
              if svc == 'web'
                snu_graphite_service_web 'web' do
                  new_resource.options.each do |k, v|
                    send(k, v) unless v.nil?
                  end
                  action act
                end
              else
                snu_graphite_service_carbon svc do
                  new_resource.options.each do |k, v|
                    send(k, v) unless v.nil?
                  end
                  action act
                end
              end
            end
          end
        end
      end
    end
  end
end
