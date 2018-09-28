# frozen_string_literal: true

#
# Cookbook:: snu_graphite
# Library:: helpers/config_carbon
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

require 'iniparse'

module SnuGraphiteCookbook
  module Helpers
    # A helper class for generating Graphite-style .ini config files. Chef is
    # packaged with the iniparse gem, which gets us most of the way there. The
    # file is essentially an .ini document, but with a little bit of a
    # difference:
    #
    #   - All keys are fully capitalized
    #   - All bolean values have the first letter capitalized
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com>
    class Config
      #
      # Initialize a new object from a config hash.
      #
      # @param hsh [Hash] a config hash
      # @return [SnuGraphiteCookbook::Helpers::Config] object
      #
      def initialize(hsh = {})
        @config = hsh || {}
      end

      #
      # Return the full string for a Graphite config file.
      #
      # @return [String] the content of the config
      #
      def to_s
        [header, body].join("\n")
      end
      alias inspect to_s

      private

      attr_accessor :config

      #
      # Return the body portion of this Graphite config.
      #
      # @return [String] the .ini content, stringified
      #
      def body
        to_ini.to_s
      end

      #
      # Convert the config hash into an .ini document object.
      #
      # @return [IniParse::Document] the .ini document
      #
      def to_ini
        IniParse.gen do |doc|
          config.each do |section, data|
            next if data.nil?
            doc.section(section) do |section|
              data.each do |k, v|
                section.option(key_for(k), value_for(v))
              end
            end
          end
        end
      end

      #
      # Return the header text for this config file.
      #
      # @return [String] header comment text
      #
      def header
        <<-CONTENT.gsub(/^ +/, '').strip
          # This file is managed by Chef.
          # Any changes to it will be overwritten.
        CONTENT
      end

      #
      # Translate a hash value into a string suitable for a Graphite config
      # using the following rules:
      #
      #   * String => String
      #   * Integer => String
      #   * Boolean => String, capitalized
      #
      # @param val [String, Integer, TrueClass, FalseClass] a value
      # @return [String] that value, ready for a config file
      #
      def value_for(val)
        case val
        when TrueClass
          'True'
        when FalseClass
          'False'
        else
          val.to_s
        end
      end

      #
      # Translate a symbolized, snake-cased key from a Ruby hash into a
      # snake-cased, all-caps string for a Graphite config.
      #
      # @param key [Symbol] a symbolized, snake-cased key from a Ruby hash
      # @return [String] that key, stringified and upcased
      def key_for(key)
        key.to_s.upcase
      end
    end
  end
end
