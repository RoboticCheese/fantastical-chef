# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/provider_fantastical_app_mac_os_x_direct'

describe Chef::Provider::FantasticalApp::MacOsX::Direct do
  let(:name) { 'default' }
  let(:new_resource) { Chef::Resource::FantasticalApp.new(name, nil) }
  let(:provider) { described_class.new(new_resource, nil) }

  describe 'URL' do
    it 'returns the correct URL' do
      expected = 'http://flexibits.com/fantastical/download'
      expect(described_class::URL).to eq(expected)
    end
  end

  describe '#install!' do
    before(:each) do
      [:download_package, :install_package].each do |m|
        allow_any_instance_of(described_class).to receive(m)
      end
    end

    it 'downloads the package' do
      expect_any_instance_of(described_class).to receive(:download_package)
      provider.send(:install!)
    end

    it 'installs the package' do
      expect_any_instance_of(described_class).to receive(:install_package)
      provider.send(:install!)
    end
  end

  describe '#install_package' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:download_path)
        .and_return('/tmp/Fantastical.zip')
    end

    it 'unzips the file into /Applications' do
      p = provider
      expect(p).to receive(:execute).with('unzip fantastical').and_yield
      expect(p).to receive(:command)
        .with('unzip -d /Applications /tmp/Fantastical.zip')
      expect(p).to receive(:action).with(:run)
      expect(p).to receive(:creates).with('/Applications/Fantastical 2.app')
      p.send(:install_package)
    end
  end

  describe '#download_package' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:remote_path)
        .and_return('http://example.com/Fantastical.zip')
      allow_any_instance_of(described_class).to receive(:download_path)
        .and_return('/tmp/Fantastical.zip')
    end

    it 'downloads the remote .zip file' do
      p = provider
      expect(p).to receive(:remote_file).with('/tmp/Fantastical.zip').and_yield
      expect(p).to receive(:source).with('http://example.com/Fantastical.zip')
      expect(p).to receive(:action).with(:create)
      expect(p).to receive(:only_if).and_yield
      expect(File).to receive(:exist?).with('/Applications/Fantastical 2.app')
      p.send(:download_package)
    end
  end

  describe '#download_path' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:remote_path)
        .and_return('http://example.com/Fantastical.zip')
    end

    it 'returns a cache path' do
      expected = "#{Chef::Config[:file_cache_path]}/Fantastical.zip"
      expect(provider.send(:download_path)).to eq(expected)
    end
  end

  describe '#remote_path' do
    let(:path) { 'http://example.com/Fantastical.zip' }
    let(:response) { { 'location' => path } }

    before(:each) do
      allow(Net::HTTP).to receive(:get_response)
        .with(URI('http://flexibits.com/fantastical/download'))
        .and_return(response)
    end

    it 'returns the redirect path' do
      p = provider
      expect(p.send(:remote_path)).to eq(path)
      expect(p.instance_variable_get(:@remote_path)).to eq(path)
    end
  end
end
