# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/helpers_app'

describe Fantastical::Helpers::App do
  describe '::URL' do
    it 'returns the expected value' do
      expected = 'http://flexibits.com/fantastical/download'
      expect(described_class::URL).to eq(expected)
    end
  end

  describe '::PATH' do
    it 'returns the expected value' do
      expect(described_class::PATH).to eq('/Applications/Fantastical 2.app')
    end
  end

  describe '.installed?' do
    let(:installed) { nil }

    before(:each) do
      allow(File).to receive(:exist?).with('/Applications/Fantastical 2.app')
        .and_return(installed)
    end

    context 'not installed' do
      let(:installed) { false }

      it 'returns false' do
        expect(described_class.installed?).to eq(false)
      end
    end

    context 'installed' do
      let(:installed) { true }

      it 'returns true' do
        expect(described_class.installed?).to eq(true)
      end
    end
  end

  describe '.enabled?' do
    let(:enabled) { nil }
    let(:shell_out) { double(stdout: enabled ? 'stuff' : '') }

    before(:each) do
      allow(described_class).to receive(:shell_out)
        .with("osascript -e 'tell application \"System Events\" to get " \
              "the name of the login item \"Fantastical 2\"' || true")
        .and_return(shell_out)
    end

    context 'not enabled' do
      let(:enabled) { false }

      it 'returns false' do
        expect(described_class.enabled?).to eq(false)
      end
    end

    context 'enabled' do
      let(:enabled) { true }

      it 'returns true' do
        expect(described_class.enabled?).to eq(true)
      end
    end
  end

  describe '.running?' do
    let(:running) { nil }
    let(:shell_out) { double(stdout: running ? 'stuff' : '') }

    before(:each) do
      allow(described_class).to receive(:shell_out)
        .with('ps -A -c -o command | grep ^Fantastical\\ 2$ || true')
        .and_return(shell_out)
    end

    context 'not running' do
      let(:running) { false }

      it 'returns false' do
        expect(described_class.running?).to eq(false)
      end
    end

    context 'running' do
      let(:running) { true }

      it 'returns true' do
        expect(described_class.running?).to eq(true)
      end
    end
  end
end
