# Encoding: UTF-8

require_relative '../../spec_helper'

class Chef
  class Provider
    # A fake mac_app_store_app provider
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class MacAppStoreApp < Provider::LWRPBase
    end
  end
end
