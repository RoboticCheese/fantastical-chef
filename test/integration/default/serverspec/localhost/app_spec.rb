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
end
