require File.join(File.dirname(__FILE__), '/dialog_handler')
#require 'win32olerot'
#require 'win32ole-pp'

module RubyUatFramework
  class FileSaveDialogHandler < DialogHandler
    def save_to(file_name)
      begin
        file_path = WinPath.temp_for(file_name)
        File.delete(file_path) if File.exists?(file_path)
        autoit = WIN32OLE.new("AutoItX3.Control")
      rescue
        cwd = File.dirname(__FILE__).gsub(%r{/}) { "\\" }
        if File.exists?("#{cwd}\\AutoItX3.dll")
          system("regsvr32 /s #{cwd}\\AutoItX3.dll")
          @@autoitx = true
        else
          puts "Unable to find AutoItX3.dll -- Aborting!!"
          exit
        end

        download_title = "File Download"
        download_message = "Do you want to open or save this file?"
        save_as_title = "Save As"
        completed_title = "Download complete"
        completed_message = "Download Complete"

        Watir::Waiter.new(timeout).wait_until{ autoit.WinExists(download_title, download_message) == 1 }
        Watir::Waiter.wait_until do
          autoit.WinActivate(download_title, download_message)
          sleep 1
          autoit.ControlClick(download_title, download_message, "&Save")
          autoit.WinExists(save_as_title) == 1
        end

        autoit.WinActivate(save_as_title)
        autoit.ControlSetText(save_as_title, "", "Edit1", file_path)

        Watir::Waiter.wait_until do
          sleep 1
          autoit.ControlClick(save_as_title, "", "&Save")
          autoit.WinExists(completed_title, completed_message) == 1
        end

        autoit.WinActivate(completed_title, completed_message)
        Watir::Waiter.wait_until do
          sleep 1
          autoit.ControlClick(completed_title, "", "Close")
          autoit.WinExists(completed_title, completed_message) == 0
        end
        @dialog_was_handled = true
        file_path
      #rescue Watir::Exception::TimeOutException
      #  @dialog_was_handled = false
      #  nil
      end
    end
  end
end