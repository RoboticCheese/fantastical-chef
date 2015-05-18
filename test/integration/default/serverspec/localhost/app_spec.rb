# Encoding: UTF-8

require_relative '../spec_helper'

describe 'Fantastical app' do
  describe package('com.flexibits.fantastical2.mac') do
    it 'is installed' do
      expect(subject).to be_installed.by(:pkgutil)
    end
  end

  describe file('/Applications/Fantastical 2.app') do
    it 'is present on the filesystem' do
      expect(subject).to be_directory
    end
  end

  describe command(
    'osascript -e \'tell application "System Events" to get the name of the ' \
    'login item "Fantastical 2"\''
  ) do
    it 'indicates Fantastical is enabled' do
      expect(subject.stdout.strip).to eq('Fantastical 2')
    end
  end

  describe process('Fantastical 2') do
    it 'is running' do
      expect(subject).to be_running
    end
  end
end
