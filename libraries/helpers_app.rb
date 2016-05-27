# Encoding: UTF-8
#
# Cookbook Name:: fantastical
# Library:: helpers_app
#
# Copyright 2015-2016 Jonathan Hartman
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

require 'chef/mixin/shell_out'

module Fantastical
  module Helpers
    # Some helper methods for interacting with the Fantastical app.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class App
      URL ||= 'http://flexibits.com/fantastical/download'.freeze
      PATH ||= '/Applications/Fantastical 2.app'.freeze

      class << self
        include Chef::Mixin::ShellOut

        #
        # Determine whether Fantastical is currently installed on the system.
        #
        # @return [TrueClass, FalseClass]
        #
        def installed?
          ::File.exist?(PATH)
        end

        #
        # Shell out and use AppleScript to check whether the "Fantastical"
        # login item already exists.
        #
        # @return [TrueClass, FalseClass]
        #
        def enabled?
          cmd = "osascript -e 'tell application \"System Events\" to get " \
                "the name of the login item \"Fantastical 2\"' || true"
          shell_out(cmd).stdout.strip.empty? ? false : true
        end

        #
        # Shell out to check whether the Fantastical process is running.
        #
        # @return [TrueClass, FalseClass]
        #
        def running?
          res = shell_out('ps -A -c -o command | grep ^Fantastical\ 2$ || true')
          res.stdout.strip.empty? ? false : true
        end
      end
    end
  end
end
