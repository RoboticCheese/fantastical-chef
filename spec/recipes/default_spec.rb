# Encoding: UTF-8

require 'spec_helper'

describe 'fantastical::default' do
  let(:platform) { { platform: 'mac_os_x', version: '10.10' } }
  let(:system_user) { nil }
  let(:runner) do
    ChefSpec::SoloRunner.new(platform) do |node|
      unless system_user.nil?
        node.set['fantastical']['system_user'] = system_user
      end
    end
  end
  let(:chef_run) { runner.converge(described_recipe) }

  context 'all default attributes' do
    it 'installs the Fantastical app' do
      expect(chef_run).to install_fantastical_app('default')
    end

    it 'enables the Fantastical app' do
      expect(chef_run).to enable_fantastical_app('default')
    end

    it 'starts the Fantastical app' do
      expect(chef_run).to start_fantastical_app('default')
    end
  end

  context 'an overridden system_user attribute' do
    let(:system_user) { 'testme' }

    it 'installs the Fantastical app' do
      expect(chef_run).to install_fantastical_app('default')
        .with(system_user: 'testme')
    end

    it 'enables the Fantastical app' do
      expect(chef_run).to enable_fantastical_app('default')
        .with(system_user: 'testme')
    end

    it 'starts the Fantastical app' do
      expect(chef_run).to start_fantastical_app('default')
        .with(system_user: 'testme')
    end
  end
end
