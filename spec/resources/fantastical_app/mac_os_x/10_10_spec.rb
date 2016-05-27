require_relative '../../../spec_helper'
require_relative '../../../../libraries/helpers_app'

describe 'resource_fantastical::mac_os_x::10_10' do
  let(:name) { 'default' }
  %i(source system_user action).each { |i| let(i) { nil } }
  %i(installed? enabled? running?).each { |i| let(i) { false } }
  let(:getlogin) { 'vagrant' }
  let(:runner) do
    ChefSpec::SoloRunner.new(
      step_into: 'fantastical_app', platform: 'mac_os_x', version: '10.10'
    ) do |node|
      %i(name source system_user action).each do |a|
        unless send(a).nil?
          node.set['resource_fantastical_app_test'][a] = send(a)
        end
      end
    end
  end
  let(:converge) { runner.converge('resource_fantastical_app_test') }

  before(:each) do
    allow(Kernel).to receive(:load).and_call_original
    allow(Kernel).to receive(:load)
      .with(%r{fantastical/libraries/helpers_app\.rb}).and_return(true)
    %i(installed? enabled? running?).each do |m|
      allow(Fantastical::Helpers::App).to receive(m).and_return(send(m))
    end
    allow(Etc).to receive(:getlogin).and_return(getlogin)
    allow(Net::HTTP).to receive(:get_response).with(
      URI('http://flexibits.com/fantastical/download')
    ).and_return('location' => 'http://example.com/fantastical.zip')
  end

  context 'the default action ([:install, :enable, :start])' do
    let(:action) { nil }
    let(:installed?) { false }
    let(:enabled?) { false }
    let(:running?) { false }
    cached(:chef_run) { converge }

    context 'the default source (:app_store)' do
      it 'configures the Mac App Store' do
        expect(chef_run).to include_recipe('mac-app-store')
      end

      it 'installs Fantastical from the App Store' do
        expect(chef_run).to install_mac_app_store_app(
          'Fantastical 2 - Calendar and Reminders'
        )
      end

      it 'enables Fantastical' do
        expect(chef_run).to run_execute('Enable Fantastical').with(
          command: "osascript -e 'tell application \"System Events\" " \
                   'to make new login item at end with properties {name: ' \
                   '"Fantastical 2", path: "/Applications/Fantastical 2' \
                   ".app\", hidden: false}'",
          user: getlogin
        )
      end

      it 'starts Fantastical' do
        expect(chef_run).to run_execute('Start Fantastical')
          .with(command: "open '/Applications/Fantastical 2.app'",
                user: getlogin)
      end
    end

    context 'the :direct source' do
      let(:source) { :direct }
      cached(:chef_run) { converge }

      it 'downloads the Fantastical app' do
        expect(chef_run).to create_remote_file(
          "#{Chef::Config[:file_cache_path]}/fantastical.zip"
        )
      end

      it 'unzips Fantastical' do
        expect(chef_run).to run_execute('Unzip Fantastical').with(
          command: "unzip -d /Applications #{Chef::Config[:file_cache_path]}" \
                   '/fantastical.zip'
        )
      end

      it 'enables Fantastical' do
        expect(chef_run).to run_execute('Enable Fantastical').with(
          command: "osascript -e 'tell application \"System Events\" " \
                   'to make new login item at end with properties {name: ' \
                   '"Fantastical 2", path: "/Applications/Fantastical 2' \
                   ".app\", hidden: false}'",
          user: getlogin
        )
      end

      it 'starts Fantastical' do
        expect(chef_run).to run_execute('Start Fantastical')
          .with(command: "open '/Applications/Fantastical 2.app'",
                user: getlogin)
      end
    end
  end

  context 'the :install action' do
    let(:action) { :install }

    context 'the default source (:app_store)' do
      let(:source) { nil }

      context 'not installed' do
        let(:installed?) { false }
        cached(:chef_run) { converge }

        it 'configures the Mac App Store' do
          expect(chef_run).to include_recipe('mac-app-store')
        end

        it 'installs Fantastical from the App Store' do
          expect(chef_run).to install_mac_app_store_app(
            'Fantastical 2 - Calendar and Reminders'
          )
        end
      end

      context 'already installed' do
        let(:installed?) { true }
        cached(:chef_run) { converge }

        it 'does not configure the Mac App Store' do
          expect(chef_run).to_not include_recipe('mac-app-store')
        end

        it 'does not install Fantastical from the App Store' do
          expect(chef_run).to_not install_mac_app_store_app(
            'Fantastical 2 - Calendar and Reminders'
          )
        end
      end
    end

    context 'the :direct source' do
      let(:source) { :direct }

      context 'not installed' do
        let(:installed?) { false }
        cached(:chef_run) { converge }

        it 'downloads the Fantastical app' do
          expect(chef_run).to create_remote_file(
            "#{Chef::Config[:file_cache_path]}/fantastical.zip"
          )
        end

        it 'unzips Fantastical' do
          expect(chef_run).to run_execute('Unzip Fantastical').with(
            command: 'unzip -d /Applications ' \
                     "#{Chef::Config[:file_cache_path]}/fantastical.zip"
          )
        end
      end

      context 'already installed' do
        let(:installed?) { true }
        cached(:chef_run) { converge }

        it 'does not configure the Mac App Store' do
          expect(chef_run).to_not include_recipe('mac-app-store')
        end

        it 'does not install Fantastical' do
          expect(chef_run).to_not install_mac_app_store_app(
            'Fantastical 2 - Calendar and Reminders'
          )
        end
      end
    end
  end

  context 'the :upgrade action' do
    let(:action) { :upgrade }

    context 'the default source (:app_store)' do
      let(:source) { nil }
      cached(:chef_run) { converge }

      it 'configures the Mac App Store' do
        expect(chef_run).to include_recipe('mac-app-store')
      end

      it 'upgrades Fantastical' do
        expect(chef_run).to upgrade_mac_app_store_app(
          'Fantastical 2 - Calendar and Reminders'
        )
      end
    end

    context 'the :direct source' do
      let(:source) { :direct }
      cached(:chef_run) { converge }

      it 'raises an error' do
        expect { chef_run }.to raise_error(Chef::Exceptions::ValidationFailed)
      end
    end
  end

  context 'the :remove action' do
    let(:action) { :remove }

    context 'the default source (:app_store)' do
      let(:source) { nil }
      cached(:chef_run) { converge }

      it 'raises an error' do
        expect { chef_run }.to raise_error(Chef::Exceptions::ValidationFailed)
      end
    end

    context 'the :direct source' do
      let(:source) { :direct }

      context 'installed' do
        let(:installed?) { true }
        cached(:chef_run) { converge }

        it 'cleans up the application directory' do
          expect(chef_run).to delete_directory(
            '/Applications/Fantastical 2.app'
          ).with(recursive: true)
        end
      end

      context 'already not installed' do
        let(:installed?) { false }
        cached(:chef_run) { converge }

        it 'does not clean up the application directory' do
          expect(chef_run).to_not delete_directory(
            '/Applications/Fantastical 2.app'
          )
        end
      end
    end
  end

  context 'the :enable action' do
    let(:action) { :enable }

    context 'not enabled' do
      let(:enabled?) { false }
      cached(:chef_run) { converge }

      it 'enables Fantastical' do
        expect(chef_run).to run_execute('Enable Fantastical').with(
          command: "osascript -e 'tell application \"System Events\" " \
                   'to make new login item at end with properties {name: ' \
                   '"Fantastical 2", path: "/Applications/Fantastical 2' \
                   ".app\", hidden: false}'",
          user: getlogin
        )
      end
    end

    context 'already enabled' do
      let(:enabled?) { true }
      cached(:chef_run) { converge }

      it 'does not enable Fantastical' do
        expect(chef_run).to_not run_execute('Enable Fantastical')
      end
    end
  end

  context 'the :disable action' do
    let(:action) { :disable }

    context 'enabled' do
      let(:enabled?) { true }
      cached(:chef_run) { converge }

      it 'disables Fantastical' do
        expect(chef_run).to run_execute('Disable Fantastical').with(
          command: "osascript -e 'tell application \"System Events\" " \
                   "to delete login item \"Fantastical 2\"'",
          user: getlogin
        )
      end
    end

    context 'already disabled' do
      let(:enabled?) { false }
      cached(:chef_run) { converge }

      it 'does not disable Fantastical' do
        expect(chef_run).to_not run_execute('Disable Fantastical')
      end
    end
  end

  context 'the :start action' do
    let(:action) { :start }

    context 'not running' do
      let(:running?) { false }
      cached(:chef_run) { converge }

      it 'starts Fantastical' do
        expect(chef_run).to run_execute('Start Fantastical').with(
          command: "open '/Applications/Fantastical 2.app'",
          user: getlogin
        )
      end
    end

    context 'already running' do
      let(:running?) { true }
      cached(:chef_run) { converge }

      it 'does not start Fantastical' do
        expect(chef_run).to_not run_execute('Start Fantastical')
      end
    end
  end

  context 'the :stop action' do
    let(:action) { :stop }

    context 'running' do
      let(:running?) { true }
      cached(:chef_run) { converge }

      it 'stops Fantastical' do
        expect(chef_run).to run_execute('Stop Fantastical').with(
          command: "killall 'Fantastical 2'",
          user: getlogin
        )
      end
    end

    context 'not running' do
      let(:running?) { false }
      cached(:chef_run) { converge }

      it 'does not stop Fantastical' do
        expect(chef_run).to_not run_execute('Stop Fantastical')
      end
    end
  end
end
