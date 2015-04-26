# Encoding: UTF-8

require_relative '../../spec_helper'

class Chef
  class Resource
    # A fake mac_app_store_app resource
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class MacAppStoreApp < Resource::LWRPBase
      self.resource_name = :mac_app_store_app
      actions :install
      default_action :install
      attribute :app_name, kind_of: String, default: name
      attribute :bundle_id, kind_of: String, default: 'com.example.app'
    end
  end
end
