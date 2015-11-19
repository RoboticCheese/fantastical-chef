# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/provider_fantastical_app_mac_os_x'

describe Chef::Provider::FantasticalApp::MacOsX do
  let(:name) { 'default' }
  let(:run_context) { ChefSpec::SoloRunner.new.converge.run_context }
  let(:new_resource) { Chef::Resource::FantasticalApp.new(name, run_context) }
  let(:provider) { described_class.new(new_resource, run_context) }

  describe '#start!' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:execute)
    end

    it 'starts up Fantastical' do
      p = provider
      expect(p).to receive(:execute).with('start fantastical').and_yield
      expect(p).to receive(:command)
        .with('open \'/Applications/Fantastical 2.app\'')
      expect(p).to receive(:user).with(Etc.getlogin)
      expect(p).to receive(:action).with(:run)
      expect(p).to receive(:only_if).and_yield
      cmd = 'ps -A -c -o command | grep ^Fantastical\ 2$'
      expect(Mixlib::ShellOut).to receive(:new).with(cmd)
        .and_return(double(run_command: double(stdout: 'test')))
      p.send(:start!)
    end
  end

  describe '#enable!' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:execute)
    end

    it 'runs an execute resource' do
      p = provider
      expect(p).to receive(:execute).with('enable fantastical').and_yield
      cmd = 'osascript -e \'tell application "System Events" to make new ' \
            'login item at end with properties {name: "Fantastical 2", ' \
            'path: "/Applications/Fantastical 2.app", hidden: false}\''
      expect(p).to receive(:command).with(cmd)
      expect(p).to receive(:action).with(:run)
      expect(p).to receive(:only_if).and_yield
      expect(p).to receive(:enabled?)
      p.send(:enable!)
    end
  end

  describe '#enabled?' do
    let(:enabled?) { nil }
    let(:stdout) { enabled? ? 'Fantastical' : '' }

    before(:each) do
      cmd = 'osascript -e \'tell application "System Events" to get the ' \
            'name of the login item "Fantastical 2"\''
      allow(Mixlib::ShellOut).to receive(:new).with(cmd)
        .and_return(double(run_command: double(stdout: stdout)))
    end

    context 'Fantastical not enabled' do
      let(:enabled?) { false }

      it 'returns false' do
        expect(provider.send(:enabled?)).to eq(false)
      end
    end

    context 'Fantastical enabled' do
      let(:enabled?) { true }

      it 'returns true' do
        expect(provider.send(:enabled?)).to eq(true)
      end
    end
  end
end
