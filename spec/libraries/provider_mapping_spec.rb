# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/provider_mapping'

describe :provider_mapping do
  let(:platform) { nil }
  let(:app_provider) do
    Chef::Platform.platforms[platform][:default][:fantastical_app]
  end

  context 'Mac OS X' do
    let(:platform) { :mac_os_x }

    it 'uses the MacAppStoreApp app provider' do
      expected = Chef::Provider::FantasticalApp::MacOsX::AppStore
      expect(app_provider).to eq(expected)
    end
  end

  context 'Ubuntu' do
    let(:platform) { :ubuntu }

    it 'returns no app provider' do
      expect(app_provider).to eq(nil)
    end
  end
end
