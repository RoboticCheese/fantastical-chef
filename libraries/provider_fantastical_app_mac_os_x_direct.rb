# Encoding: UTF-8
#
# Cookbook Name:: fantastical
# Library:: provider_fantastical_app_mac_os_x_direct
#
# Copyright 2015 Jonathan Hartman
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

require 'net/http'
require 'chef/provider/lwrp_base'
require_relative 'provider_fantastical_app'
require_relative 'provider_fantastical_app_mac_os_x'

class Chef
  class Provider
    class FantasticalApp < Provider::LWRPBase
      class MacOsX < FantasticalApp
        # A Chef provider for OS X installs via direct download.
        #
        # @author Jonathan Hartman <j@p4nt5.com>
        class Direct < MacOsX
          URL ||= 'http://flexibits.com/fantastical/download'

          private

          #
          # Download and install the package. The download URL redirects to a
          # .zip file hosted behind Flexibits' CDN.
          #
          # (see FantasticalApp#install!)
          #
          def install!
            download_package
            install_package
          end

          #
          # Use an execute resource to extract the downloaded .zip file
          # package.
          #
          def install_package
            path = download_path
            execute 'unzip fantastical' do
              command "unzip -d /Applications #{path}"
              action :run
              creates PATH
            end
          end

          #
          # Use a remote_file resource to download the .zip file package.
          #
          def download_package
            s = remote_path
            remote_file download_path do
              source s
              action :create
              only_if { !::File.exist?(PATH) }
            end
          end

          #
          # Construct the local path to download the package file to.
          #
          def download_path
            ::File.join(Chef::Config[:file_cache_path],
                        ::File.basename(remote_path))
          end

          #
          # Follow the redirect from URL to get the .zip file download path.
          # Save it as an instance variable so we only have to hit the web
          # server once.
          #
          # @return [String]
          #
          def remote_path
            @remote_path ||= Net::HTTP.get_response(URI(URL))['location']
          end
        end
      end
    end
  end
end
