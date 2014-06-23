module RubyUatFramework
  class BrowserSourceSnapshotHandler
    attr_accessor :output_path

    def initialize(output_path)
      @output_path = output_path
    end

    def save_source_snapshot(browser, scenario_name)
      Dir.mkdir(@output_path) if not File.exist?(@output_path)
      puts "Capturing browser source snapshot of failed scenario..."
      snapshot_name = @output_path + '/' + scenario_name + '.html'
      File.open(snapshot_name, 'w') {|f| f.write(browser.html) }
      puts "##teamcity[publishArtifacts '#{snapshot_name}']"
    end
  end
end