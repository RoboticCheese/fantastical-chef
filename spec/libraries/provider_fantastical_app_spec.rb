# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/provider_fantastical_app'

describe Chef::Provider::FantasticalApp do
  let(:name) { 'default' }
  let(:run_context) { ChefSpec::SoloRunner.new.converge.run_context }
  let(:new_resource) { Chef::Resource::FantasticalApp.new(name, run_context) }
  let(:provider) { described_class.new(new_resource, run_context) }

  describe '#whyrun_supported?' do
    it 'returns true' do
      expect(provider.whyrun_supported?).to eq(true)
    end
  end

  describe '#action_install' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:install!)
    end

    it 'calls the child `install!` method ' do
      expect_any_instance_of(described_class).to receive(:install!)
      provider.action_install
    end

    it 'sets the resource installed status' do
      p = provider
      p.action_install
      expect(p.new_resource.installed?).to eq(true)
    end
  end

  describe '#action_enable' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:enable!)
    end

    it 'calls the child `enable!` method ' do
      expect_any_instance_of(described_class).to receive(:enable!)
      provider.action_enable
    end

    it 'sets the resource enabled status' do
      p = provider
      p.action_enable
      expect(p.new_resource.enabled?).to eq(true)
    end
  end

  describe '#action_start' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:start!)
    end

    it 'calls the child `start!` method' do
      expect_any_instance_of(described_class).to receive(:start!)
      provider.action_start
    end

    it 'sets the resource running status' do
      p = provider
      p.action_start
      expect(p.new_resource.running?).to eq(true)
    end
  end

  [:start!, :enable!, :install!].each do |m|
    describe "##{m}" do
      it 'raises an error' do
        expect { provider.send(m) }.to raise_error(NotImplementedError)
      end
    end
  end
end
