# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/provider_fantastical_app_mac_os_x_app_store'

describe Chef::Provider::FantasticalApp::MacOsX::AppStore do
  let(:name) { 'default' }
  let(:run_context) { ChefSpec::SoloRunner.new.converge.run_context }
  let(:new_resource) { Chef::Resource::FantasticalApp.new(name, run_context) }
  let(:provider) { described_class.new(new_resource, run_context) }

  describe '#install!' do
    before(:each) do
      [:include_recipe, :mac_app_store_app].each do |r|
        allow_any_instance_of(described_class).to receive(r)
      end
    end

    it 'opens the Mac App Store' do
      p = provider
      expect(p).to receive(:include_recipe).with('mac-app-store')
      p.send(:install!)
    end

    it 'installs the app from the App Store' do
      p = provider
      expect(p).to receive(:mac_app_store_app)
        .with('Fantastical 2 - Calendar and Reminders').and_yield
      expect(p).to receive(:bundle_id).with('com.flexibits.fantastical2.mac')
      expect(p).to receive(:action).with(:install)
      p.send(:install!)
    end
  end
end
