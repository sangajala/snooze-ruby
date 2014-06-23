#require File.join(File.dirname(__FILE__), '/firewatir') if not ENV['capybara']
#require 'watir'
require 'watir'
module RubyUatFramework
  module World
    attr_accessor :screenshot_handler
    attr_accessor :browser_source_snapshot_handler

    @@rpc_error_avoidiance_browser = nil
    @@screenshot_enabled = true
    @@ie8 = !ENV['capybara']

    def World.cucumber_hooks=(cucumber_hooks)
      @@cucumber_hooks = cucumber_hooks
    end
    def World.cucumber_hooks
      @@cucumber_hooks
    end

    def World.extended(obj)
      @@cucumber_hooks.register(obj)
    end

    def World.screenshot_enabled(value)
      @@screenshot_enabled = value if not value.nil?
      @@screenshot_enabled
    end

    def World.ie8?
      @@ie8
    end

    def World.ie6?
      (!@@ie8) && (!ENV['capybara'])
    end

    def World.ie8=(value)
      @@ie8 = value
    end

    def World.ie6=(value)
      @@ie8 = (not value)
    end

    def before
      ensure_ie_window_open
    end

    def after(scenario)
      if (scenario.class.to_s =~ /OutlineTable/)
        scenario_name = scenario.name.gsub /[^\w\-]/, ' '
        after_scenario_outline(scenario, scenario_name)
      else
        scenario_name = scenario.to_sexp[3].gsub /[^\w\-]/, ' '
        after_scenario(scenario, scenario_name)
      end
    end

    def after_scenario(scenario, scenario_name)
      if(scenario.status == :failed)
        save_browser_source(scenario_name) if running_on_teamcity
        save_screenshot(scenario_name) if running_on_teamcity
      end
      close_browser
    end

    def after_scenario_outline(scenario_outline, scenario_outline_name)
      if(scenario_outline.status == :failed)
        save_browser_source(scenario_outline_name) if running_on_teamcity
        save_screenshot(scenario_outline_name) if running_on_teamcity
      end
      close_browser
    end

    def running_on_teamcity
      not ENV['TEAMCITY_PROJECT_NAME'].nil?
    end

    def on_exit
      close_all_ie_windows
      cleanup_recover_files if World.ie8?
    end

    def cleanup_recover_files
      recovery_directory = ENV['USERPROFILE'] + '\Local Settings\Application Data\Microsoft\Internet Explorer\Recovery\Active'
      delete_recovery_files = "del \"#{recovery_directory}\\\*.*\" /Q"
      system(delete_recovery_files)
    end

    def close_browser
      @browser.close if @browser
      @browser = nil
    end

    def World.close_all_ie_windows
      if not ENV['capybara']
        result = `taskkill /IM iexplore.exe /T /F /FI "STATUS eq RUNNING"`
        sleep 10 if result =~ /SUCCESS/
      end
    end

    def close_all_ie_windows
      World.close_all_ie_windows
    end

    def World.ensure_ie_window_open
      if not ENV['capybara']
        return @@rpc_error_avoidiance_browser if (@@rpc_error_avoidiance_browser and @@rpc_error_avoidiance_browser.exists?)
        Watir::IE.each{|b| return @@rpc_error_avoidiance_browser = b if b.exists?}
        @@rpc_error_avoidiance_browser = Watir::IE.new
      end
    end

    def ensure_ie_window_open
      World.ensure_ie_window_open
    end

    def browser
      @browser ||= FireWatir::Firefox.new if ENV['watir_browser'] == 'firefox'
      @browser ||= Watir::IE.new
    end

    def save_browser_source(scenario_name)
      if(!ENV['capybara'])
        @browser_source_snapshot_handler ||= BrowserSourceSnapshotHandler.new(File.expand_path(File.dirname(__FILE__) + '/../../FailedScenariosScreenshots/'))
        @browser_source_snapshot_handler.save_source_snapshot(browser, scenario_name)
      end
    end

    def save_screenshot(scenario_name)
      if(@@screenshot_enabled)
          @screenshot_handler ||= ScreenshotHandler.new(File.expand_path(File.dirname(__FILE__) + '/../../FailedScenariosScreenshots/'))
          @screenshot_handler.save_screenshot(scenario_name)
      end
    end
  end
end
RubyUatFramework::World.cucumber_hooks = RubyUatFramework::CucumberHooks.new