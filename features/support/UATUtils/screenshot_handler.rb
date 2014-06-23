module RubyUatFramework
  class ScreenshotHandler
    attr_accessor :output_path

    def initialize(output_path)
      @output_path = output_path
      @cmd_path = File.expand_path(File.dirname(__FILE__) + '/screenshot-cmd.exe')
    end

    def save_screenshot(scenario_name)
      Dir.mkdir(@output_path) if not File.exist?(@output_path)
      puts "Taking screenshot of failed scenario..."
      screenshot_name = @output_path + '/' + scenario_name + '.png'
      cmd = @cmd_path + ' -o "' + screenshot_name + '"'
      %x{#{cmd}}
      puts "##teamcity[publishArtifacts '#{screenshot_name}']"
    end
  end
end
