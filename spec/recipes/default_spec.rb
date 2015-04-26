# Encoding: UTF-8

require 'spec_helper'

describe 'fantastical::default' do
  let(:platform) { nil }
  let(:runner) { ChefSpec::SoloRunner.new(platform) }
  let(:chef_run) { runner.converge(described_recipe) }

  context 'Mac OS X platform' do
    let(:platform) { { platform: 'mac_os_x', version: '10.10' } }

    it 'runs the mac-app-store default recipe' do
      expect(chef_run).to include_recipe('mac-app-store')
    end

    it 'installs the Fantastical app' do
      expect(chef_run).to install_fantastical_app('default')
    end
  end
end
