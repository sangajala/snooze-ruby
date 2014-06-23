if not ENV['capybara']
  require 'watir'
  require File.join(File.dirname(__FILE__), 'world')

  #if Watir::IE::VERSION != '1.6.5'
  #  #ensures that watir has been loaded so that we can override the file field
  #  RubyUatFramework::World.ensure_ie_window_open
  #
  #  class Watir::FileField < Watir::InputElement
  #    INPUT_TYPES = ["file"]
  #    POPUP_TITLES = ['Choose file', 'Choose File to Upload']
  #
  #    def set(path_to_file)
  #      assert_exists
  #      require 'watir/windowhelper'
  #      WindowHelper.check_autoit_installed
  #      begin
  #        Thread.new do
  #          sleep 1 # it takes some time for popup to appear
  #
  #          system %{ruby -e '
  #              require "win32ole"
  #
  #              @autoit = WIN32OLE.new("AutoItX3.Control")
  #              time    = Time.now
  #
  #              while (Time.now - time) < 15 # the loop will wait up to 15 seconds for popup to appear
  #                #{POPUP_TITLES.inspect}.each do |popup_title|
  #                  next unless @autoit.WinWait(popup_title, "", 1) == 1
  #
  #                  @autoit.ControlSetText(popup_title, "", "Edit1", #{path_to_file.inspect})
  #                  @autoit.ControlSend(popup_title, "", "Button2", "{ENTER}")
  #                  exit
  #                end # each
  #              end # while
  #          '}
  #        end.join(1)
  #      rescue
  #        raise Watir::Exception::WatirException, "Problem accessing Choose file dialog"
  #      end
  #      click
  #    end
  #  end
  #end
end