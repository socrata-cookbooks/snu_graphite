# frozen_string_literal: true

#
# Cookbook:: snu_graphite
# Library:: resource/snu_graphite_service_carbon
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

require_relative 'snu_graphite_base'

class Chef
  class Resource
    # A resource for managing the cache, relay, and/or aggregator Carbon
    # services. Initially, the only supported init system is runit, to match
    # v1.0.4 of the community graphite cookbook. Support for Systemd and/or
    # Upstart may be added in the future.
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com
    class SnuGraphiteServiceCarbon < SnuGraphiteBase
      provides :snu_graphite_service_carbon

      property :service_name,
               [String, Symbol],
               default: lazy { |r| r.name.split(':').first.to_sym },
               equal_to: %i[cache relay aggregator]
      property :instance,
               [String, Symbol, nil],
               default: lazy { |r|
                 inst = r.name.split(':')[1]
                 inst.nil? ? nil : inst.to_sym
               }
      property :file_limit, Integer, default: 1024

      default_action %i[create enable start]


      #
      # Ensure runit is installed and then create the service configs.
      #
      action :create do
        include_recipe 'runit'

        runit_service_resource(:create)
      end

      #
      # The runit_service resource doesn't have a :remove or :delete action, so
      # we'll have to fake it.
      #
      action :remove do
        directory ::File.join('/etc/sv', full_service_name) do
          recursive true
          action :delete
        end
      end

      #
      # Every other supported action should be passed on to an underlying
      # runit_service resource.
      # The runit_service resource only declares its allowed actions at the
      # instance level, so we have to declare a fake one to get that info.
      #
      #
      Chef::Resource::RunitService.new('fake', nil).allowed_actions
                                                   .each do |act|
        next if %i[create remove].include?(act)

        action(act) { runit_service_resource(act) }
      end

      action_class do
        #
        # Build a reusable runit_service resource, since all our actions need
        # one.
        #
        # @param act [Symbol] the action for the service
        #
        def runit_service_resource(act)
          runit_service full_service_name do
            cookbook 'snu_graphite'
            run_template_name 'carbon'
            default_logger true
            finish_script_template_name 'carbon'
            finish true
            options runit_service_options
            action act
          end
        end

        #
        # Build the hash of options that should be passed to our
        # `runit_service` resources.
        #
        # @return [Hash] the runit service options
        #
        def runit_service_options
          {
            service: new_resource.service_name,
            instance: new_resource.instance,
            user: new_resource.user,
            file_limit: new_resource.file_limit,
            graphite_path: new_resource.graphite_path,
            storage_path: new_resource.storage_path
          }
        end

        #
        # Build out the full service name by prepending "carbon-" and appending
        # the instance ID if one was given.
        #
        # @return [String] the full service name
        #
        def full_service_name
          ['carbon', new_resource.service_name, new_resource.instance].compact
                                                                      .join('-')
        end
      end
    end
  end
end
