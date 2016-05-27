# Encoding: UTF-8
#
# Cookbook Name:: fantastical
# Library:: resource_fantastical_app
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

require 'chef/resource'
require_relative 'helpers_app'

class Chef
  class Resource
    # A Chef resource for the Fantastical app.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class FantasticalApp < Resource
      URL ||= 'http://flexibits.com/fantastical/download'.freeze
      PATH ||= '/Applications/Fantastical 2.app'.freeze

      provides :fantastical_app, platform_family: 'mac_os_x'

      default_action %i(install enable start)

      #
      # Allow the user to choose from installing via the :app_store (default)
      # or a :direct download from Fantastical's site.
      #
      property :source,
               Symbol,
               coerce: proc { |v| v.to_sym },
               equal_to: %i(app_store direct),
               default: :app_store,
               desired_state: false

      #
      # The system user to shell out as for starting and stopping Fantastical.
      #
      property :system_user, String, default: Etc.getlogin, desired_state: false

      #
      # State properties for the app's installed, enabled, and running status.
      #
      %i(installed enabled running).each do |p|
        property p, [TrueClass, FalseClass]
      end

      #
      # Figure out if Fantastical is currently installed, enabled, running.
      #
      load_current_value do
        installed(Fantastical::Helpers::App.installed?)
        enabled(Fantastical::Helpers::App.enabled?)
        running(Fantastical::Helpers::App.running?)
      end

      #
      # Install Fantastical, either from the App Store or via direct download.
      #
      action :install do
        new_resource.installed(true)

        converge_if_changed :installed do
          case new_resource.source
          when :app_store
            include_recipe 'mac-app-store'
            mac_app_store_app 'Fantastical 2 - Calendar and Reminders'
          when :direct
            remote_path = Net::HTTP.get_response(URI(URL))['location']
            local_path = ::File.join(Chef::Config[:file_cache_path],
                                     ::File.basename(remote_path))
            remote_file(local_path) { source remote_path }
            execute 'Unzip Fantastical' do
              command "unzip -d /Applications #{local_path}"
            end
          end
        end
      end

      #
      # If this is an App Store install, upgrades are also possible.
      #
      action :upgrade do
        unless new_resource.source == :app_store
          raise(Chef::Exceptions::ValidationFailed,
                'The :upgrade action can only be done on :app_store installs')
        end
        include_recipe 'mac-app-store'
        mac_app_store_app 'Fantastical 2 - Calendar and Reminders' do
          action :upgrade
        end
      end

      #
      # If this is a direct download install, uninstallation is possible.
      #
      action :remove do
        unless new_resource.source == :direct
          raise(Chef::Exceptions::ValidationFailed,
                'The :remove action can only be done on :direct installs')
        end

        new_resource.installed(false)

        converge_if_changed :installed do
          directory PATH do
            recursive true
            action :delete
          end
        end
      end

      #
      # Shell out to osascript to create a Fantastical 2 login item.
      #
      action :enable do
        new_resource.enabled(true)

        converge_if_changed :enabled do
          execute 'Enable Fantastical' do
            command "osascript -e 'tell application \"System Events\" " \
                    'to make new login item at end with properties {name: ' \
                    "\"Fantastical 2\", path: \"#{PATH}\", hidden: false}'"
            user new_resource.system_user
          end
        end
      end

      #
      # Shell out to osascript to delete the Fantastical 2 login item.
      #
      action :disable do
        new_resource.enabled(false)

        converge_if_changed :enabled do
          execute 'Disable Fantastical' do
            command "osascript -e 'tell application \"System Events\" " \
                    "to delete login item \"Fantastical 2\"'"
            user new_resource.system_user
          end
        end
      end

      #
      # Shell out to start Fantastical.
      #
      action :start do
        new_resource.running(true)

        converge_if_changed :running do
          execute 'Start Fantastical' do
            command "open '#{PATH}'"
            user new_resource.system_user
          end
        end
      end

      #
      # Kill any running Fantastical process.
      #
      action :stop do
        new_resource.running(false)

        converge_if_changed :running do
          execute 'Stop Fantastical' do
            command "killall 'Fantastical 2'"
            user new_resource.system_user
          end
        end
      end
    end
  end
end
