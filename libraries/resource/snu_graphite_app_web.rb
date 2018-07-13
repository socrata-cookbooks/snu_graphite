# frozen_string_literal: true

#
# Cookbook:: snu_graphite
# Library:: resource/snu_graphite_app_web
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
require_relative 'snu_graphite_app_base'

class Chef
  class Resource
    # A resource for managing the Web app.
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com
    class SnuGraphiteAppWeb < Resource
      provides :snu_graphite_app_web

      property :django_version, String, default: '1.5.5'

      # Inherit all the base resource's properties as well.
      Chef::Resource::SnuGraphiteAppBase.state_properties.each do |prop|
        property prop.name, prop.options
      end

      default_action :install

      #
      # Build on the base :install action to install graphite-web into the
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

        python_package 'django' do
          version new_resource.django_version
          virtualenv new_resource.graphite_path
        end

        python_package 'django-tagging' do
          version '0.3.6'
          virtualenv new_resource.graphite_path
        end

        python_package %w[pytz pyparsing python-memcached uwsgi] do
          virtualenv new_resource.graphite_path
        end

        python_package 'graphite-web' do
          version new_resource.version
          virtualenv new_resource.graphite_path
        end
      end

      #
      # Uninstall graphite-web and related  packages. Any other cleanup (e.g.
      # users, graphite dirs, etc.) should be done with a
      # `snu_graphite_app_base('default') { action :remove }` lest we risk
      # unintentionally installing another app that happens to be using the
      # same virtualenv.
      #
      action :remove do
        pkgs = %w[
          graphite-web
          pytz
          pyparsing
          python-memcached
          uwsgi
          django-tagging
          django
        ]
        python_package pkgs do
          virtualenv new_resource.graphite_path
          action :remove
        end
      end
    end
  end
end
