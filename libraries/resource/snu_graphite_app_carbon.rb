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
require 'json'
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

        # Carbon's dependencies need to be installed first so they go in the
        # proper graphite/lib/python2.7/site-packages. If we let Carbon pull
        # them in, they go with it in graphite/lib and it can't find them at
        # import time.
        #
        # To make things more complicated, at least in older versions, the
        # requirements.txt in Carbon's GitHub repo contains different
        # dependencies than get pulled down with PyPi.
        python_package 'Twisted' do
          version new_resource.twisted_version
          virtualenv new_resource.graphite_path
          user new_resource.user
          group new_resource.group
        end

        # At least as of 0.9.12, Carbon's requirements.txt in GitHub reflects a
        # different set of dependencies than pip pulls down from PyPi.
        python_package %w[whisper txAMQP] do
          virtualenv new_resource.graphite_path
          user new_resource.user
          group new_resource.group
        end

        # The python_package resource doesn't have an environment property and
        # we need to set PYTHONPATH for pip to be okay with Carbon's custom
        # install path.
        python_execute 'Install Carbon' do
          command '-m pip.__main__ install --no-binary=:all: ' \
                  "--install-option='--prefix=#{new_resource.graphite_path}' " \
                  "--install-option='--install-lib=#{new_resource.graphite_path}/lib' " \
                  "carbon==#{new_resource.version}"
          virtualenv new_resource.graphite_path
          user new_resource.user
          group new_resource.group
          environment 'PYTHONPATH' => ::File.join(new_resource.graphite_path, 'lib')
          not_if do
            pip = ::File.join(new_resource.graphite_path, 'bin/pip')
            env = { 'PYTHONPATH' => ::File.join(new_resource.graphite_path,
                                                'lib') }
            sh = shell_out!("#{pip} list --format=json", env: env)
            carbon = JSON.parse(sh.stdout).find { |i| i['name'] == 'carbon' }
            !carbon.nil? && carbon['version'] == new_resource.version
          end
        end
      end

      #
      # Uninstall Carbon and its dependencies. Any other cleanup (e.g. users,
      # graphite dirs, etc.) should be done with a
      # `snu_graphite_app_base('default') { action :remove }` lest we risk
      # unintentionally installing another app that happens to be using the
      # same virtualenv.
      #
      action :remove do
        python_execute 'Uninstall Carbon' do
          command '-m pip.__main__ uninstall carbon'
          virtualenv new_resource.graphite_path
          environment 'PYTHONPATH' => ::File.join(new_resource.graphite_path,
                                                  'lib')
          only_if do
            pip = ::File.join(new_resource.graphite_path, 'bin/pip')
            env = { 'PYTHONPATH' => ::File.join(new_resource.graphite_path,
                                                'lib') }
            sh = shell_out!("#{pip} list --format=json", env: env)
            JSON.parse(sh.stdout).map { |i| i['name'] }.include?('carbon')
          end
        end

        python_package %w[txAMQP whisper Twisted] do
          virtualenv new_resource.graphite_path
          action :remove
        end
      end
    end
  end
end
