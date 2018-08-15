# frozen_string_literal: true

require 'chef/resource'

class Chef
  class Resource
    # A stub python_execute resource. So much happens at compile time with
    # runtime and execute resources finding each other and Chefspec doesn't
    # play well with it.
    #
    # @author Jonathan Hartman <jonathan.hartman@socrata.com>
    class PythonExecute < Resource
      provides :python_execute

      property :command, String
      property :virtualenv, String
      property :user, String
      property :group, String
      property :environment, Hash

      action :run do
      end
    end
  end
end
