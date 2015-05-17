# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/resource_fantastical_app'

describe Chef::Resource::FantasticalApp do
  let(:name) { 'default' }
  let(:resource) { described_class.new(name, nil) }

  describe '#initialize' do
    it 'sets the correct resource name' do
      exp = :fantastical_app
      expect(resource.instance_variable_get(:@resource_name)).to eq(exp)
    end

    it 'sets the correct supported actions' do
      expected = [:nothing, :install, :enable, :start]
      expect(resource.instance_variable_get(:@allowed_actions)).to eq(expected)
    end

    it 'sets the correct default action' do
      expected = [:install, :enable, :start]
      expect(resource.instance_variable_get(:@action)).to eq(expected)
    end

    it 'sets the installed status to nil' do
      expect(resource.instance_variable_get(:@installed)).to eq(nil)
    end

    it 'sets the enabled status to nil' do
      expect(resource.instance_variable_get(:@enabled)).to eq(nil)
    end

    it 'sets the running status to nil' do
      expect(resource.instance_variable_get(:@running)).to eq(nil)
    end
  end

  [:installed, :installed?].each do |m|
    describe "##{m}" do
      context 'default unknown installed status' do
        it 'returns nil' do
          expect(resource.send(m)).to eq(nil)
        end
      end

      context 'app installed' do
        let(:resource) do
          r = super()
          r.instance_variable_set(:@installed, true)
          r
        end

        it 'returns true' do
          expect(resource.send(m)).to eq(true)
        end
      end

      context 'app not installed' do
        let(:resource) do
          r = super()
          r.instance_variable_set(:@installed, false)
          r
        end

        it 'returns false' do
          expect(resource.send(m)).to eq(false)
        end
      end
    end
  end

  [:enabled, :enabled?].each do |m|
    describe "##{m}" do
      context 'default unknown enabled status' do
        it 'returns nil' do
          expect(resource.send(m)).to eq(nil)
        end
      end

      context 'app enabled' do
        let(:resource) do
          r = super()
          r.instance_variable_set(:@enabled, true)
          r
        end

        it 'returns true' do
          expect(resource.send(m)).to eq(true)
        end
      end

      context 'app disabled' do
        let(:resource) do
          r = super()
          r.instance_variable_set(:@enabled, false)
          r
        end

        it 'returns false' do
          expect(resource.send(m)).to eq(false)
        end
      end
    end
  end

  [:running, :running?].each do |m|
    describe "##{m}" do
      context 'default unknown running status' do
        it 'returns nil' do
          expect(resource.send(m)).to eq(nil)
        end
      end

      context 'app running' do
        let(:resource) do
          r = super()
          r.instance_variable_set(:@running, true)
          r
        end

        it 'returns true' do
          expect(resource.send(m)).to eq(true)
        end
      end

      context 'app not running' do
        let(:resource) do
          r = super()
          r.instance_variable_set(:@running, false)
          r
        end

        it 'returns false' do
          expect(resource.send(m)).to eq(false)
        end
      end
    end
  end
end
